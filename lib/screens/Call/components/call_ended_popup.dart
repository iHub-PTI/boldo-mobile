import 'package:flutter/material.dart';
import 'dart:core';

import '../../Dashboard/DashboardScreen.dart';
import '../../../constants.dart';

Future<bool> callEndedPopup({@required BuildContext context}) async {
  return showDialog<bool>(
      useRootNavigator: false,
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
                  width: 300,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        "Consulta Finalizada",
                        style: TextStyle(
                            color: Constants.otherColor100,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Image.asset(
                        'assets/images/Avatar.png',
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        "Dra. Susan Giménez",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Constants.extraColor400,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        "Dermatología",
                        textAlign: TextAlign.center,
                        style: boldoSubTextStyle,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Fecha",
                              style: boldoHeadingTextStyle,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text("Lunes 7 de septiembre del 2020",
                                style:
                                    boldoSubTextStyle.copyWith(fontSize: 16)),
                            const SizedBox(
                              height: 24,
                            ),
                            const Text(
                              "Hora",
                              style: boldoHeadingTextStyle,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              "14:30 horas",
                              style: boldoSubTextStyle.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Constants.primaryColor500,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(),
                              ),
                            );
                          },
                          child: const Text("Aceptar")),
                      const SizedBox(
                        height: 32,
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
