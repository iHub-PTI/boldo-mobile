import 'dart:core';
import 'dart:io';
import 'package:boldo/constants.dart';
import 'package:boldo/environment.dart';
import 'package:boldo/utils/errors.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/backdrop_modal/backdrop_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String? selectedAudioOutput;
  bool interactAudioOutputs = false;

  PeerConnection? peerConnection;

  io.Socket? socket;

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  MediaStream? localStream;

  String socketsAddress = environment.SOCKETS_ADDRESS;

  List<MediaDeviceInfo> _mediaDevicesList = [];

  @override
  void initState() {
    super.initState();
    navigator.mediaDevices.ondevicechange = (event) async {

      // get news devices
      await updateDevices();

      setState(() {

      });
    };
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
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      Navigator.of(context).pop({"tokenError": true});
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      Navigator.of(context).pop({"tokenError": true});
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
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

    // get devices available
    await updateDevices();

    if(localStream == null){
      return;
    }
    if (localStream?.getAudioTracks() != null) {
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
    Helper.switchCamera(localStream!.getVideoTracks()[0]);
  }

  Future<void> updateDevices() async {
    //set devices available
    _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
  }

  void muteMic() {
    final newState = !localStream!.getAudioTracks()[0].enabled;
    localStream!.getAudioTracks()[0].enabled = newState;
  }

  Widget configIcon({ButtonStyle? buttonStyle}){

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Visibility(
              visible: (_mediaDevicesList.where((element) => element.kind == 'audiooutput').length?? 0) > 1,
              child: ElevatedButton(
                style: buttonStyle?? elevatedButtonStyleSecondary,
                onPressed: (){
                  setState(() {
                    interactAudioOutputs = true;
                  });
                  List<Widget> audioOutputs =_mediaDevicesList
                      .where((device) => device.kind == 'audiooutput')
                      .map((device) {
                    return PopupMenuItem<String>(
                      onTap: () => _selectAudioOutput(device.deviceId),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(
                              selectedAudioOutput == device.deviceId
                                  ? Icons.radio_button_checked_sharp
                                  : Icons.radio_button_unchecked_sharp,
                              color: selectedAudioOutput == device.deviceId
                                  ? ConstantsV2.secondaryRegular
                                  : ConstantsV2.activeText,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              translateInputDevice(label: device.label),
                              style: boldoCardSubtitleTextStyle.copyWith(
                                color: ConstantsV2.darkText,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList();
                  Navigator.push(
                    context,
                    BackdropModalRoute<void>(
                      overlayContentBuilder: (context) {
                        Helper.audiooutputs.then((value) => {
                          value.forEach((element) {
                            print(element.label);
                          })
                        }
                        );

                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  "Seleccione la salida de audio",
                                  style: boldoScreenTitleTextStyle.copyWith(
                                      color: ConstantsV2.activeText
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: ConstantsV2.BGNeutral,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Column(
                                  children: audioOutputs,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.volume_up_sharp,
                        color: ConstantsV2.lightest,
                      ),
                      if(!interactAudioOutputs)
                        const SizedBox(width: 8,),
                      Flexible(
                        child: AnimatedSize(
                          duration: const Duration(seconds: 1),
                          child: Container(
                            width: !interactAudioOutputs? null: 0.0,
                            child: Visibility(
                              visible: !interactAudioOutputs,
                              child: Text(
                                "Seleccione la salida de audio",
                                style: GoogleFonts.montserrat().copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 6,
                                  color: ConstantsV2.grayLightest,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAudioOutput(String deviceId) {
    //change audio output
    Helper.selectAudioOutput(deviceId);

    // set audioOutput to show device selected
    selectedAudioOutput = deviceId;
  }

  void muteVideo() {
    final newState = !localStream!.getVideoTracks()[0].enabled;
    localStream!.getVideoTracks()[0].enabled = newState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            callStatus
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
                  configAudioOutput: configIcon(),
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
              configIcon: configIcon(),
            ),
          ],
        )
      ),
    );
  }

  String translateInputDevice({required String label}){
    try {
      if (label.toUpperCase().contains("Speaker".toUpperCase())) {
        return "Altavoz";
      } else if (label.toUpperCase().contains("Earpiece".toUpperCase())) {
        return "Telefono";
      } else if (label.toUpperCase().contains("Headset".toUpperCase())) {
        return "Auricular";
      } else {
        return label;
      }
    }catch (exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
        data: {
          'entrada': label,
          'so': Platform.operatingSystem,
        },
      );
      return 'Desconocido';
    }
  }

}
