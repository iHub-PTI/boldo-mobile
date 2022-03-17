import 'package:flutter/material.dart';
import 'dart:core';

import '../../../constants.dart';

class ConnectionProblemPopup extends StatelessWidget {
  const ConnectionProblemPopup({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                backgroundColor: Constants.primaryColor600,
              ),
              const SizedBox(height: 24),
              const Text(
                "¡Oops! Conexión perdida",
                style: TextStyle(
                    color: Constants.extraColor400,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
              const Text(
                "Estamos tratando de reconectarte.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Constants.extraColor300,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
