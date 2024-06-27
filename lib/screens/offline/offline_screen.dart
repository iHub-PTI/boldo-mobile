import 'package:boldo/constants.dart';
import 'package:boldo/network/connection_status.dart';
import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi,
                color: Constants.extraColor200,
                size: 80,
              ),
              const SizedBox(
                height: 17,
              ),
              Text(
                '¿Sin internet?',
                style: boldoHeadingTextStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(
                height: 26,
              ),
              const Text(
                'Al parecer hay un problema con \n tu conexión. Porfavor revisa el \n estado de tu internet para \n continuar.',
                style: boldoSubTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  backgroundColor: const Color(0xffF98080),
                ),
                onPressed: () async {
                  final connectionStatus =
                      ConnectionStatusSingleton.getInstance();
                  final hasInternet = await connectionStatus.checkConnection();
                  if (hasInternet) {
                    Navigator.of(context).pop();

                    return;
                  }
                },
                child: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
