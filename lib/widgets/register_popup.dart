import 'package:flutter/material.dart';
import 'dart:core';

import '../constants.dart';
import '../screens/dashboard/dashboard_screen.dart';

Future<bool?> notLoggedInPop({required BuildContext context}) async {
  return showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (
        BuildContext context,
      ) {
        bool _loading = false;
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Center(
              child: Card(
                elevation: 11,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(34),
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        width: 256,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "¡No estás registrado!",
                              style: TextStyle(
                                  color: Constants.extraColor400,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Por favor, inicie sesión o \n regístrese antes de continuar.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Constants.extraColor300,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text(
                                    "Cancelar",
                                    style: TextStyle(
                                      color: Constants.primaryColor600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _loading = true;
                                    });
                                    await authenticateUser(
                                        context: context, switchPage: false);

                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text("Continuar"),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
              ),
            ),
          );
        });
      });
}
