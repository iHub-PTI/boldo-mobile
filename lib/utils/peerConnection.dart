import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

Map<String, dynamic> _iceServers = {
  'iceServers': [
    {
      'urls': "turn:coturn.pti.org.py:3478",
      'username': "coturn",
      'credential': "VHJ1cGVyMjB4MjB4Lgo"
    },
    {
      'urls': "stun:coturn.pti.org.py:3478",
      'username': "coturn",
      'credential': "VHJ1cGVyMjB4MjB4Lgo"
    }
  ]
};

enum CallState {
  CallConnected,
  CallDisconnected,
  CallClosed,
}

class PeerConnection {
  RTCPeerConnection peerConnection;

  MediaStream localStream;
  io.Socket socket;
  String room;
  String token;

  Function(MediaStream) onRemoteStream;
  Function(CallState) onStateChange;

  PeerConnection(
      {this.localStream,
      @required this.token,
      @required this.room,
      @required this.socket});

  Future<void> init() async {
    peerConnection = await createPeerConnection(
      _iceServers,
    );

    //
    // 1.
    // Handle Audio/Video Tracks
    //

    // Handle outgoing tracks
    peerConnection.addStream(localStream);

    // Handle incoming tracks
    void onAddStream(MediaStream stream) {
      onRemoteStream(stream);
    }

    //
    // 2.
    // Handle SDP Offers
    //

    // See setSdpOffer function below

    //
    // 3.
    // Handle ICE Candidates
    //

    // Handle outgoing candidates
    void onIceCandidate(candidate) {
      final iceCandidate = {
        'sdpMLineIndex': candidate.sdpMlineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      };
      socket.emit(
          'ice candidate', {'room': room, 'ice': iceCandidate, "token": token});
    }

    // Handle incoming candidates
    socket.on('ice candidate', (message) async {
      // The last ICE candidate is always null
      if (message["ice"] == null) return;

      RTCIceCandidate candidate = RTCIceCandidate(message["ice"]['candidate'],
          message["ice"]['sdpMid'], message["ice"]['sdpMLineIndex'] ?? 1);

      await peerConnection.addCandidate(candidate);
    });

    //
    // 4.
    // Handle State Changes
    //

    // Handle |iceconnectionstatechange| events. This will detect
    // when the ICE connection is closed, failed, or disconnected.
    //
    // This is called when the state of the ICE agent changes.
    //
    // Important for us as this is the main source about failed conections

    void onIceConnectionState(state) {
      print(state);
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
          {
            onStateChange(CallState.CallConnected);
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          {
            onStateChange(CallState.CallDisconnected);
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          {
            onStateChange(CallState.CallClosed);
            break;
          }
          break;
        default:
          break;
      }
    }

    peerConnection.onAddStream = onAddStream;
    peerConnection.onIceCandidate = onIceCandidate;
    peerConnection.onIceConnectionState = onIceConnectionState;
  }

  Future<void> setSdpOffer(message) async {
    RTCSessionDescription description =
        RTCSessionDescription(message["sdp"]['sdp'], message["sdp"]['type']);
    await peerConnection.setRemoteDescription(description);

    RTCSessionDescription s = await peerConnection.createAnswer({
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': []
    });
    peerConnection.setLocalDescription(s);

    socket.emit('sdp offer', {
      'room': room,
      'sdp': {'sdp': s.sdp, 'type': s.type},
      "token": token
    });
  }

  void cleanup() async {
    print('🧹🧹🧹 CLEANUP 🧹🧹🧹');
    socket.off('ice candidate');

    await peerConnection.close();

    peerConnection.onAddStream = null;
    peerConnection.onIceCandidate = null;
    peerConnection.onIceConnectionState = null;

    peerConnection = null;
  }
}
