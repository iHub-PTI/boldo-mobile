import 'package:flutter/material.dart';
import 'dart:core';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

Future<bool> waitingRoomModal(
    {@required BuildContext context,
    @required RTCVideoRenderer localRenderer,
    @required handleBackButton}) async {
  return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (
        BuildContext context,
      ) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Card(
                elevation: 11,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        "En breve Dr. House iniciará \n la videollamada",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.5,
                            color: Constants.extraColor300,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      OrientationBuilder(
                        builder: (context, orientation) {
                          return Container(
                            color: Colors.white,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                              child: Container(
                                width: orientation == Orientation.portrait
                                    ? 200
                                    : 266,
                                height: orientation == Orientation.portrait
                                    ? 266
                                    : 200,
                                child: RTCVideoView(localRenderer),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      ),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                ),
                              ),
                              onPressed: () {
                                print("press");
                              },
                              child: SvgPicture.asset(
                                  "assets/icon/videocam.svg",
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          SizedBox(
                            height: 48,
                            width: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Constants.primaryColor500,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
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
                      const SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: () async {
                          bool popupResponse = await handleBackButton();
                          if (popupResponse) {
                            Navigator.of(context).pop();
                          }
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
              ),
            ),
          ),
        );
      });
}
