import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';

import 'websocket.dart';

enum SignalingState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
  ConnectionEndedByDoctor
}

/*
 * callbacks for Signaling API.
 */
typedef void SignalingStateCallback(SignalingState state);
typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);

class Signaling {
  SimpleWebSocket _socket;
  String remoteUser;
  RTCPeerConnection peerConnection;

  var _remoteCandidates = [];

  MediaStream _localStream;
  List<MediaStream> _remoteStreams;
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  OtherEventCallback onPeersUpdate;
  OtherEventCallback onEventUpdate;

  String roomNumber;

  Signaling(this.roomNumber);

  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      //  {"url": "stun:stun.stunprotocol.org"},
      // {
      //   "url": "turn:numb.viagenie.ca",
      //   "credential": 'muazkh',
      //   "username": 'webrtc@live.com',
      // },
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  void close() {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    if (peerConnection != null) {
      peerConnection.close();
      peerConnection = null;
    }
    if (_socket != null) {
      _send('disconnect', {});
      _socket.close();
    }
  }

  void switchCamera() {
    if (_localStream != null) {
      _localStream.getVideoTracks()[0].switchCamera();
    }
  }

  void bye({bool doctorDisconnect = false}) {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    if (peerConnection != null) {
      peerConnection.close();
    }

    _remoteCandidates.clear();
    _socket.close();

    if (onStateChange != null) {
      if (doctorDisconnect != null && doctorDisconnect == true) {
        onStateChange(SignalingState.ConnectionEndedByDoctor);
      } else {
        onStateChange(SignalingState.CallStateBye);
      }
    }
  }

  void onMessage(tag, message) async {
    switch (tag) {
      case 'offer':
        {
          var id = 'caller';
          var sdp = message["sdp"];
          var callerID = message["caller"];
          var media = 'call';

          if (onStateChange != null) {
            onStateChange(SignalingState.CallStateNew);
          }

          var pc = await _createPeerConnection(id, media, false);
          peerConnection = pc;

          await pc.setRemoteDescription(
              RTCSessionDescription(sdp['sdp'], sdp['type']));
          await _createAnswer(id, pc, media, callerID);
          if (_remoteCandidates.isNotEmpty) {
            _remoteCandidates.forEach((candidate) async {
              await pc.addCandidate(candidate);
            });
            _remoteCandidates.clear();
          }
        }
        break;
      case 'answer':
        {
          var sdp = message["sdp"];
          var pc = peerConnection;
          if (pc != null) {
            await pc.setRemoteDescription(
                RTCSessionDescription(sdp['sdp'], sdp['type']));
          }
        }
        break;
      case 'ice-candidate':
        {
          var candidateMap =
              message["candidate"] is String ? message : message["candidate"];
          if (candidateMap != null) {
            var pc = peerConnection;

            RTCIceCandidate candidate = RTCIceCandidate(
                candidateMap['candidate'],
                candidateMap['sdpMid'],
                candidateMap['sdpMLineIndex'] ?? 1);
            if (pc != null) {
              await pc.addCandidate(candidate);
            } else {
              _remoteCandidates.add(candidate);
            }
          }
        }
        break;
      case 'call partner':
        {
          String peerId = message;
          String media = "video";
          bool useScreen = false;
          remoteUser = message;
          if (onStateChange != null) {
            onStateChange(SignalingState.CallStateNew);
          }

          _createPeerConnection(peerId, media, useScreen, isHost: false)
              .then((pc) {
            peerConnection = pc;

            _createOffer(peerId, pc, media);
          });
        }
        break;
      case 'call host':
        {
          remoteUser = message;
        }
        break;
      default:
        break;
    }
  }

  void connect() async {
    String socketsAddress = DotEnv().env['SOCKETS_ADDRESS'];

    if (_socket != null) {
      _socket.close();
      _socket = null;
    }
    _socket = SimpleWebSocket(socketsAddress, roomNumber);

    _socket.onOpen = () {
      this?.onStateChange(SignalingState.ConnectionOpen);
    };

    _socket.onMessage = (tag, message) {
      print('Received data: $tag - $message');
      onMessage(tag, message);
    };

    _socket.onClose = (int code, String reason) {
      print('Closed by server [$code => $reason]!');
      if (onStateChange != null) {
        onStateChange(SignalingState.ConnectionClosed);
      }
    };

    _socket.connect();
  }

  Future<MediaStream> createStream(media, userScreen) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    MediaStream stream = userScreen
        ? await MediaDevices.getDisplayMedia(mediaConstraints)
        : await MediaDevices.getUserMedia(mediaConstraints);
    if (onLocalStream != null) {
      onLocalStream(stream);
    }
    return stream;
  }

  Future<dynamic> _createPeerConnection(id, media, userScreen,
      {isHost = false}) async {
    if (media != 'data') _localStream = await createStream(media, userScreen);
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    if (media != 'data') pc.addStream(_localStream);
    pc.onIceCandidate = (candidate) {
      final iceCandidate = {
        'sdpMLineIndex': candidate.sdpMlineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      };
      emitIceCandidateEvent(iceCandidate);
    };

    pc.onIceConnectionState = (state) {
      Logger logger = Logger();
      logger.i(state);
      if (state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        bye(doctorDisconnect: true);
      }
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        //close the timeout popup;
        print("CONNECTED");
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        print("CLOSED OR FAILED");
        bye();
      }
    };

    pc.onAddStream = (stream) {
      if (onAddRemoteStream != null) onAddRemoteStream(stream);
      //_remoteStreams.add(stream);
    };

    pc.onRemoveStream = (stream) {
      if (onRemoveRemoteStream != null) onRemoveRemoteStream(stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    return pc;
  }

  Future<void> _createOffer(
      String id, RTCPeerConnection pc, String media) async {
    try {
      RTCSessionDescription s =
          await pc.createOffer(media == 'data' ? _dcConstraints : _constraints);
      pc.setLocalDescription(s);

      final sdp = {'sdp': s.sdp, 'type': s.type};
      emitOfferEvent(sdp);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _createAnswer(
      String id, RTCPeerConnection pc, media, String callerID) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dcConstraints : _constraints);
      pc.setLocalDescription(s);

      final sdp = {'sdp': s.sdp, 'type': s.type};
      emitAnswerEvent(sdp, callerID);
    } catch (e) {
      print(e.toString());
    }
  }

  void _send(event, data) {
    _socket.send(event, data);
  }

  void emitOfferEvent(sdp) {
    _send('offer',
        {'caller': _socket.socket.id, "target": remoteUser, 'sdp': sdp});
  }

  void emitAnswerEvent(sdp, callerID) {
    _send('answer',
        {'sdp': sdp, "target": callerID, "caller": _socket.socket.id});
  }

  void emitIceCandidateEvent(candidate) {
    _send('ice-candidate', {'target': remoteUser, 'candidate': candidate});
  }
}
