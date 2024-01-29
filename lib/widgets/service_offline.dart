import 'package:boldo/constants.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';

Future<bool?> serviceOfflinePopUp({required BuildContext context}) async {
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
                    ? Padding(
                  padding: const EdgeInsets.all(34),
                  child: loadingStatus(),
                )
                    : Container(
                  width: 256,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "¡Servicio no disponible!",
                        style: TextStyle(
                            color: Constants.extraColor400,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Por favor, reintente más tarde.",
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
                              "Aceptar",
                              style: TextStyle(
                                color: Constants.primaryColor600,
                              ),
                            ),
                          ),
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