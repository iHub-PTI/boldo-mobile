import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:boldo/models/Appointment.dart';
import 'package:boldo/screens/Call/components/call.dart';
import 'package:boldo/screens/Call/components/waiting_room.dart';
import 'package:boldo/screens/Call/components/connection_problem_popup.dart';
import 'package:boldo/utils/peerConnection.dart';

class VideoCall extends StatefulWidget {
  final Appointment appointment;
  VideoCall({Key key, @required this.appointment}) : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  bool callStatus = false;
  bool isDisconnected = false;

  PeerConnection peerConnection;

  io.Socket socket;

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  MediaStream localStream;

  String socketsAddress = String.fromEnvironment('SOCKETS_ADDRESS',
      defaultValue: DotEnv().env['SOCKETS_ADDRESS']);

  @override
  void initState() {
    super.initState();

    // Manual connection required here. Otherwise socket will not reconnect.
    socket = io.io(socketsAddress, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    socket.connect();

    socket.emit('patient ready', widget.appointment.id);

    socket.on('find patient', (data) {
      if (callStatus) return;
      socket.emit('patient ready', widget.appointment.id);
    });

    initCall();
  }

  Future<void> initCall() async {
    // FIXME: This will throw an error if permission is denied
    // Catch the error and show a smooth UI
    try {
      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'}
      });
    } catch (e) {
      print(e);
      Navigator.of(context)
          .pop({"error": "You have to give access to your camera."});
    }

    // initialize the video renderers
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    localRenderer.srcObject = localStream;

    void onRemoteStream(MediaStream stream) {
      remoteRenderer.srcObject = stream;
    }

    void onStateChange(CallState status) {
      switch (status) {
        case CallState.CallConnected:
          {
            setState(() {
              isDisconnected = false;
              callStatus = true;
            });
            socket.emit('patient in call', widget.appointment.id);
            break;
          }
        case CallState.CallDisconnected:
          {
            setState(() {
              isDisconnected = true;
            });
            break;
          }
        case CallState.CallClosed:
          {
            if (peerConnection != null) peerConnection.cleanup();
            setState(() {
              callStatus = false;
            });
            socket.emit('patient ready', widget.appointment.id);
            socket.emit('ready!', widget.appointment.id);
            break;
          }
        default:
          {
            setState(() {
              isDisconnected = false;
            });
            break;
          }
      }
    }

    // Ready. Wait for start.
    socket.on('sdp offer', (message) async {
      print('offer');

      if (peerConnection != null) peerConnection.cleanup();

      //initialize the peer connection
      peerConnection = PeerConnection(
        localStream: localStream,
        room: widget.appointment.id,
        socket: socket,
      );

      peerConnection.onRemoteStream = onRemoteStream;
      peerConnection.onStateChange = onStateChange;

      await peerConnection.init();
      print('setting description');
      await peerConnection.setSdpOffer(message);
    });

    // Inform Doctor that we are ready.
    socket.emit('ready!', widget.appointment.id);
    socket.on('ready?', (message) {
      print('ready!');
      socket.emit('ready!', widget.appointment.id);
    });

    socket.on('end call', (data) {
      Navigator.of(context).pop({"appointment": widget.appointment});
    });

    // This is a rerender for the camera
    setState(() {});
  }

  @override
  void dispose() {
    //cleanup the socket
    socket.clearListeners();
    socket.dispose();
    socket = null;

    // cleanup the video renderers
    localRenderer.dispose();
    remoteRenderer.dispose();

    //cleanup the peer connection
    if (peerConnection != null) peerConnection.cleanup();
    super.dispose();
  }

  void hangUp() {
    socket.emit('end call', widget.appointment.id);
    Navigator.of(context).pop();
  }

  void switchCamera() {
    if (localStream == null) return;
    localStream.getVideoTracks()[0].switchCamera();
  }

  void muteMic() {
    final newState = !localStream.getAudioTracks()[0].enabled;
    localStream.getAudioTracks()[0].enabled = newState;
  }

  void muteVideo() {
    final newState = !localStream.getVideoTracks()[0].enabled;
    localStream.getVideoTracks()[0].enabled = newState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: callStatus
          ? Stack(
              children: [
                Call(
                  muteVideo: muteVideo,
                  initialVideoState: localStream.getVideoTracks()[0].enabled,
                  initialMicState: localStream.getAudioTracks()[0].enabled,
                  muteMic: muteMic,
                  localRenderer: localRenderer,
                  remoteRenderer: remoteRenderer,
                  hangUp: hangUp,
                  switchCamera: switchCamera,
                  appointment: widget.appointment,
                ),
                if (isDisconnected)
                  const Align(
                    alignment: Alignment.center,
                    child: ConnectionProblemPopup(),
                  )
              ],
            )
          : WaitingRoom(
              localRenderer: localRenderer,
              appointment: widget.appointment,
              muteMic: muteMic,
              muteVideo: muteVideo,
            ),
    );
  }
}
