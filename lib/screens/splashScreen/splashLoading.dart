import 'dart:io';
import 'dart:ui';

import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Splash extends StatelessWidget {
  const Splash({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget background = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            ConstantsV2.gradientStart,
            ConstantsV2.gradientEnd,
          ],
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icon/boldo-splash-icon.svg',
          color: Colors.white,
          height: 240,
          width: 240,
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            background,
          ],
        )
      ),
    );

  }

  Widget getAppVersion(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: const LinearProgressIndicator(
              color: Constants.primaryColor500,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          Text(
            "Obteniendo información de la versión",
            style: boldoCardHeadingTextStyle,
          ),
        ],
      ),
    );
  }
}

class SplashFailed extends StatelessWidget {
  const SplashFailed({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget background = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            ConstantsV2.gradientStart,
            ConstantsV2.gradientEnd,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Error al obtener la version, intentelo mas tarde',
                style: boldoCardHeadingTextStyle,
              ),
            ),
          ],
        )
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Stack(
            children: [
              background,
            ],
          )
      ),
    );

  }

  Widget getAppVersion(){
    return Container(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: const LinearProgressIndicator(
              color: Constants.primaryColor500,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          Text(
            "Obteniendo información de la versión",
            style: boldoCardHeadingTextStyle,
          ),
        ],
      ),
    );
  }
}

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget background = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            ConstantsV2.gradientStart,
            ConstantsV2.gradientEnd,
          ],
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icon/boldo-splash-icon.svg',
          color: Colors.white,
          height: 240,
          width: 240,
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Stack(
              children: [
                background,
                getAppVersion(context),
              ],
            )
        ),
      )
    );

  }

  Widget getAppVersion(BuildContext context){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Hay una nueva versión disponible a la cual debe de actualizar",
              style: boldoCardHeadingTextStyle,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _launchURL,
                    child: const Text("Actualizar")
                ),
                // TODO: continue with tne normal process or restart the app
                /*
                ElevatedButton(
                    onPressed: (){
                      _continueWithoutUpdate(context);
                    },
                    child: const Text("Continuar")
                ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL() async {
    String url = Platform.isAndroid? 'https://play.google.com/store/apps/details?id=py.org.pti.boldo':'https://apps.apple.com/us/app/boldo/id1614655648';
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Failure('No se puede abrir $url');
    }
  }

  void _continueWithoutUpdate(BuildContext context) async {

    try{
      String session = await storage.read(key: "access_token")?? '';
      // FIXME: this cause problem because MaterialAppRoute was already launched
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => FullApp(onboardingCompleted: session),
        ),
            (route) => false,
      );
    }catch (exception, stackTrace) {
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            'patient': prefs.getString("userId"),
            'access_token': await storage.read(key: 'access_token'),
          },
          stackTrace
        ]
      );
    }
  }
}