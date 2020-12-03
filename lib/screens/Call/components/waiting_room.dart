import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:boldo/models/Appointment.dart';
import 'package:boldo/constants.dart';
import '../../../utils/helpers.dart';

class WaitingRoom extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final Appointment appointment;
  final Function() muteMic;
  final Function() muteVideo;
  const WaitingRoom({
    Key key,
    @required this.localRenderer,
    @required this.appointment,
    @required this.muteMic,
    @required this.muteVideo,
  }) : super(key: key);

  @override
  _WaitingRoomState createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoom> {
  bool _mutedMic = false;
  bool _mutedVideo = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(
          vertical: 23,
          horizontal: 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sala de espera",
              style: TextStyle(
                  color: Constants.extraColor400,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "En breve ${getDoctorPrefix(widget.appointment.doctor.gender)}${widget.appointment.doctor.familyName} iniciará \n la videollamada",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  height: 1.5,
                  color: Constants.extraColor300,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
            const SizedBox(height: 24),
            OrientationBuilder(
              builder: (context, orientation) {
                return Container(
                  color: Colors.white,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                    child: Container(
                      width: orientation == Orientation.portrait ? 200 : 266,
                      height: orientation == Orientation.portrait ? 266 : 200,
                      child: RTCVideoView(widget.localRenderer),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 48,
                  width: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      primary: Constants.primaryColor500,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    onPressed: () {
                      widget.muteVideo();
                      setState(() {
                        _mutedVideo = !_mutedVideo;
                      });
                    },
                    child: Icon(
                      _mutedVideo ? Icons.videocam_off : Icons.videocam,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      primary: Constants.primaryColor500,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    onPressed: () {
                      widget.muteMic();
                      setState(() {
                        _mutedMic = !_mutedMic;
                      });
                    },
                    child: Icon(
                      _mutedMic ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () async {
                Navigator.of(context).pop();
              },
              child: Text(
                'Salir de la sala',
                style: boldoSubTextStyle.copyWith(
                    color: Constants.secondaryColor500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
