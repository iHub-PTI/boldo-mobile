import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:boldo/models/Appointment.dart';
import 'package:boldo/constants.dart';

class WaitingRoom extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final Appointment appointment;
  const WaitingRoom({
    Key key,
    @required this.localRenderer,
    @required this.appointment,
  }) : super(key: key);

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
              "En breve ${appointment.doctor.givenName} ${appointment.doctor.familyName} iniciará \n la videollamada",
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
                      child: RTCVideoView(localRenderer),
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
                      primary: Constants.primaryColor500,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    onPressed: () {
                      print("press");
                    },
                    child: SvgPicture.asset("assets/icon/videocam.svg",
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 40),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Constants.primaryColor500,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    onPressed: () {
                      print("press");
                    },
                    child: SvgPicture.asset("assets/icon/mic.svg",
                        color: Colors.white),
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
