import 'package:flutter/material.dart';
import 'dart:core';

import '../../../constants.dart';

Future<bool> connectionProblemPopup(
    {@required BuildContext context, @required leaveScreenCallback}) async {
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
                  width: 256,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "¡Oops! Conexión perdida",
                        style: TextStyle(
                            color: Constants.extraColor400,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        "El doctor intentará llamarte nuevamente.",
                        style: TextStyle(
                            color: Constants.extraColor300,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Constants.primaryColor500,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                            ),
                          ),
                          onPressed: () {
                            print("press");
                          },
                          child: const Text("Ir a sala de espera"),
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: OutlinedButton(
                            onPressed: leaveScreenCallback,
                            child: const Text(
                              "Salir de la consulta",
                              style: TextStyle(color: Constants.extraColor400),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
}
