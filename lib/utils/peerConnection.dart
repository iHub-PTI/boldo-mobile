import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class PeerConnection {
  RTCPeerConnection peerConnection;

  MediaStream localStream;
  io.Socket socket;
  String room;

  PeerConnection(
      {this.localStream, @required this.room, @required this.socket});
}
