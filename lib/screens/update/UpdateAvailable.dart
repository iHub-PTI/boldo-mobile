import 'dart:async';

import 'package:boldo/app_config.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/utils/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAvailable extends StatefulWidget {
  final String onboardingCompleted;
  final isRequiredUpdate;
  UpdateAvailable({
    Key? key,
    required this.onboardingCompleted,
    required this.isRequiredUpdate,
  }) : super(key: key);

  @override
  _UpdateAvailableState createState() => _UpdateAvailableState();
}

class _UpdateAvailableState extends State<UpdateAvailable> {

  String downloadAppUrl = appConfig.APP_URL_DOWNLOAD;

  // in case the app url can't open
  String downloadDefaultAppUrl = appConfig.APP_URL_DOWNLOAD;

  bool isRequiredUpdated= false;

  @override
  void initState() {
    // listen changes of appUrls
    appConfig.streamAppUrlDownload.listen((event) {

      //reload page
      setState(() {
        downloadAppUrl = event;
      });
    });
    appConfig.streamDefaultAppUrlDownload.listen((event) {

      //reload page
      setState(() {
        downloadDefaultAppUrl = event;
      });
    });

    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: SvgPicture.asset(
                          'assets/Logo.svg',
                          width: 200,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 55),
                      child: Column(
                        children: [
                          Container(
                            child: SvgPicture.asset(
                              'assets/icon/updateAvailable.svg',
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.isRequiredUpdate? mandatoryUpdate() : recommendedUpdate(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget recommendedUpdate(){
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Container(
                child: const Text(
                  'Nueva actualización disponible',
                  style: TextStyle(
                    color: ConstantsV2.activeText,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  'Te recomendamos actualizar la versión '
                      'para utilizar nuestras nuevas '
                      'funcionalidades',
                  style: bodyMediumRegular.copyWith(
                      color: ConstantsV2.activeText
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 32,
        ),
        updatedButton(),
        ignoreUpdate(),
      ],
    );
  }

  Widget ignoreUpdate(){
    return TextButton(
        onPressed: (){
          Navigator.pushNamedAndRemoveUntil(
            context,
            widget.onboardingCompleted,
            (route) => false
          );
        },
        child: Text('Ignorar'));
  }

  Widget mandatoryUpdate(){
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Container(
                child: const Text(
                  'Actualización requerida',
                  style: TextStyle(
                    color: ConstantsV2.activeText,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  'La versión instalada no está vigente. '
                      'Actualizá a la nueva versión para '
                      'continuar utilizando la aplicación',
                  style: bodyMediumRegular.copyWith(
                      color: ConstantsV2.activeText
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 32,
        ),
        updatedButton(),
      ],
    );
  }

  Widget updatedButton(){
    return GestureDetector(
      onTap: () async {
        if(await canLaunch(downloadAppUrl))
          launch(downloadAppUrl);
        else
          launch(downloadDefaultAppUrl);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: ConstantsV2.secondaryRegular,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                child: Row(
                  children: [
                    Text(
                      "Buscar",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: ConstantsV2.grayLightest,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }
}
