import 'package:boldo/environment.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

Map<String, dynamic> _iceServers = {
  "sdpSemantics": "plan-b",
  'iceServers': [
    environment.ICE_SERVER_TURN_CONFIG,
    environment.ICE_SERVER_STUN_CONFIG,
  ]
};

enum CallState {
  CallConnected,
  CallDisconnected,
  CallClosed,
}

class PeerConnection {
  RTCPeerConnection? peerConnection;

  MediaStream localStream;

  late Function(MediaStream) _onRemoteStream;
  late Function(CallState) _onStateChange;
  late Function(RTCIceCandidate?) _onIceCandidateChange;

  PeerConnection({
    required this.localStream,
    required Function(MediaStream) onRemoteStream,
    required Function(CallState) onStateChange,
    required Function(RTCIceCandidate?) onIceCandidateChange,
  }){
    _onRemoteStream = onRemoteStream;
    _onStateChange = onStateChange;
    _onIceCandidateChange = onIceCandidateChange;
  }


  Future<void> init() async {
    peerConnection = await createPeerConnection(
      _iceServers,
    );

    //
    // 1.
    // Handle Audio/Video Tracks
    //

    // Handle outgoing tracks
    peerConnection?.addStream(localStream);

    // Handle incoming tracks
    void onAddStream(MediaStream stream) {
      _onRemoteStream(stream);
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
    void onIceCandidate(RTCIceCandidate? candidate) {
      // RTCIceCandidate

      _onIceCandidateChange(candidate);
    }

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
            _onStateChange(CallState.CallConnected);
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          {
            _onStateChange(CallState.CallDisconnected);
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          {
            _onStateChange(CallState.CallClosed);
            break;
          }
        default:
          break;
      }
    }

    peerConnection?.onAddStream = onAddStream;
    peerConnection?.onIceCandidate = onIceCandidate;
    peerConnection?.onIceConnectionState = onIceConnectionState;
  }

  Future<RTCSessionDescription?> setSdpOffer(message) async {
    RTCSessionDescription description =
        RTCSessionDescription(message["sdp"]['sdp'], message["sdp"]['type']);
    await peerConnection?.setRemoteDescription(description);

    if (peerConnection != null) {
      RTCSessionDescription s = await peerConnection!.createAnswer({
        'mandatory': {
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': true,
        },
        'optional': []
      });
      peerConnection?.setLocalDescription(s);
      return s;
    }
  }

  Future<void> onIceCandidateReceive(dynamic message) async {
    // The last ICE candidate is always null
    if (message["ice"] == null) return;

    RTCIceCandidate candidate = RTCIceCandidate(message["ice"]['candidate'],
        message["ice"]['sdpMid'], message["ice"]['sdpMLineIndex'] ?? 1);

    await peerConnection?.addCandidate(candidate);
  }


  void cleanup() async {
    print('🧹🧹🧹 CLEANUP 🧹🧹🧹');

    await peerConnection?.close();

    peerConnection?.onAddStream = null;
    peerConnection?.onIceCandidate = null;
    peerConnection?.onIceConnectionState = null;

    peerConnection = null;
  }
}
