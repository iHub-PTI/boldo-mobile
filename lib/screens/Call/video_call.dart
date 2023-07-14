import 'dart:core';
import 'package:boldo/constants.dart';
import 'package:boldo/environment.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:wakelock/wakelock.dart';

import '../../main.dart';
import '../../network/http.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/screens/Call/components/call.dart';
import 'package:boldo/screens/Call/components/waiting_room.dart';
import 'package:boldo/screens/Call/components/connection_problem_popup.dart';
import 'package:boldo/utils/peerConnection.dart';

class VideoCall extends StatefulWidget {
  final Appointment appointment;
  VideoCall({Key? key, required this.appointment}) : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  String? token;
  bool _loading = true;

  bool callStatus = false;
  bool isDisconnected = false;

  PeerConnection? peerConnection;

  io.Socket? socket;

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  MediaStream? localStream;

  String socketsAddress = environment.SOCKETS_ADDRESS;

  @override
  void initState() {
    super.initState();
    _getCallToken();
    Wakelock.enable();
  }

  Future _getCallToken() async {
    try {
      Response response;
      if(!(prefs.getBool(isFamily)?? false))
        response = await dio
            .get("/profile/patient/appointments/${widget.appointment.id}");
      else
        response = await dio.get(
            "/profile/caretaker/dependent/${patient.id}/appointments/${widget.appointment.id}");

      if (response.data["token"] == null ||
          response.data["token"] == "" ||
          response.data["token"].length < 1) {
        Navigator.of(context).pop({"tokenError": true});
        return;
      }
      token = response.data["token"];

      // Manual connection required here. Otherwise socket will not reconnect.
      socket = io.io(socketsAddress, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false
      });
      socket!.connect();

      socket!.emit(
          'patient ready', {"room": widget.appointment.id, "token": token});

      socket!.on('find patient', (data) {
        if (callStatus) return;
        socket!.emit(
            'patient ready', {"room": widget.appointment.id, "token": token});
      });

      initCall();
      setState(() {
        _loading = false;
      });
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      Navigator.of(context).pop({"tokenError": true});
    } catch (exception, stackTrace) {
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      Navigator.of(context).pop({"tokenError": true});
    }
  }

  Future<void> initCall() async {
    // initialize the video renderers
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    if(!await checkMicrophonePermission(context: context) || ! await checkCameraPermission(context: context)){
      Navigator.pop(context);
      return;
    }
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
    if(localStream == null){
      return;
    }
    if (localStream!.getAudioTracks() != null) {
      localStream!.getAudioTracks().forEach((track) {
        track.enableSpeakerphone(true);
      });
    }
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
            socket!.emit('patient in call',
                {"room": widget.appointment.id, "token": token});
            break;
          }
        case CallState.CallDisconnected:
          {
            setState(() {
              isDisconnected = true;
            });
            // notify again that the patient is waiting in room to repeat negotiation
            if (socket != null) {
              socket!.emit('patient ready',
                  {"room": widget.appointment.id, "token": token});
            }
            break;
          }
        case CallState.CallClosed:
          {
            if (peerConnection != null) peerConnection!.cleanup();
            // setState(() {
            //   callStatus = false;
            // });
            callStatus = false;
            if (socket != null) {
              socket!.emit('patient ready',
                  {"room": widget.appointment.id, "token": token});
              socket!.emit(
                  'ready!', {"room": widget.appointment.id, "token": token});
            }
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
    socket!.on('sdp offer', (message) async {
      print('offer');

      //if (peerConnection != null) peerConnection!.cleanup();

      if (localStream != null && socket != null && token != null) {
        //initialize the peer connection
        peerConnection = PeerConnection(
            localStream: localStream!,
            room: widget.appointment.id!,
            socket: socket!,
            token: token!);

        peerConnection!.onRemoteStream = onRemoteStream;
        peerConnection!.onStateChange = onStateChange;

        await peerConnection!.init();
        print('setting description');
        await peerConnection!.setSdpOffer(message);
      }
    });

    // Inform Doctor that we are ready.
    socket!.emit('ready!', {"room": widget.appointment.id, "token": token});
    socket!.on('ready?', (message) {
      print('ready!');
      socket!.emit('ready!', {"room": widget.appointment.id, "token": token});
    });

    socket!.on('end call', (data) {
      Navigator.of(context).pop({"appointment": widget.appointment});
    });

    // This is a rerender for the camera
    setState(() {});
  }

  @override
  void dispose() {
    Wakelock.disable();
    //cleanup the socket
    if (socket != null) {
      socket!.clearListeners();
      socket!.dispose();
      socket = null;
    }
    // cleanup the video renderers
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    localRenderer.dispose();
    remoteRenderer.dispose();
    localStream?.dispose();

    //cleanup the peer connection
    if (peerConnection != null) peerConnection!.cleanup();
    super.dispose();
  }

  Future<void> hangUp() async {
    socket!.emit('end call', {"room": widget.appointment.id, "token": token});
    Navigator.of(context).pop();
  }

  void switchCamera() {
    if (localStream == null) return;
    localStream!.getVideoTracks()[0].switchCamera();
  }

  void muteMic() {
    final newState = !localStream!.getAudioTracks()[0].enabled;
    localStream!.getAudioTracks()[0].enabled = newState;
  }

  void muteVideo() {
    final newState = !localStream!.getVideoTracks()[0].enabled;
    localStream!.getVideoTracks()[0].enabled = newState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : callStatus
              ? Stack(
                  children: [
                    Call(
                      muteVideo: muteVideo,
                      initialVideoState:
                          localStream!.getVideoTracks()[0].enabled,
                      initialMicState: localStream!.getAudioTracks()[0].enabled,
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
