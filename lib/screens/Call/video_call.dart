import 'dart:core';
import 'package:boldo/screens/call/components/waiting_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../utils/peerConnection.dart';

class VideoCall extends StatefulWidget {
  final String appointmentId;
  VideoCall({Key key, @required this.appointmentId}) : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  PeerConnection peerConnection;

  io.Socket socket;

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  MediaStream localStream;

  String socketsAddress = String.fromEnvironment('SOCKETS_ADDRESS',
      defaultValue: DotEnv().env['SOCKETS_ADDRESS']);

  @override
  void initState() {
    super.initState();
    socket = io.io(socketsAddress, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.emit('patient ready', widget.appointmentId);
    //FIXME: turn off the listener once the call has started
    //if (_inCalling) socket.off("find patient");
    socket.on('find patient', (data) {
      socket.emit('patient ready', widget.appointmentId);
    });

    initCall();
  }

  Future<void> initCall() async {
    localStream = await MediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'}
    });
    //initialize the peer connection
    peerConnection = PeerConnection(
      localStream: localStream,
      room: widget.appointmentId,
      socket: socket,
    );

    await localRenderer.initialize();
    await _remoteRenderer.initialize();
    localRenderer.srcObject = localStream;
    //FIXME: find a way to show the camera without setState
    setState(() {});
  }

  @override
  void dispose() {
    //cleanup the peer connection

    //cleanup the socket
    if (socket != null) {
      socket.disconnect();
      socket.clearListeners();
    }

    localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaitingRoom(
        localRenderer: localRenderer,
      ),
    );
  }
}
