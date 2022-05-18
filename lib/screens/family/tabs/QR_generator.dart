import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:boldo/screens/register/dni_register.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../main.dart';
import 'family_register_account.dart';

class QRGenerator extends StatelessWidget {
  const QRGenerator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(
            children: [
              const Background(text: "linkFamily"),
              SafeArea(
                child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Mi Familia",
                              style: boldoTitleBlackTextStyle.copyWith(
                                  color: ConstantsV2.activeText
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                "Boldo te permite designar a una persona de tu "
                                    "confianza para la gestión de tu perfil de salud.",
                                style: boldoSubTextMediumStyle.copyWith(
                                    color: ConstantsV2.activeText
                                ),
                              ),
                            ),
                            const SizedBox(height: 20,),
                            Flexible(
                              child: Text(
                                "Mostrale este código para darle acceso",
                                style: boldoSubTextMediumStyle.copyWith(
                                    color: ConstantsV2.activeText
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child:Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(vertical: 80, horizontal: 58),
                          child: QrImage(
                            data: patient.identifier!,
                            embeddedImage: const AssetImage('assets/images/logo.png'),
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.circle,
                              color: Colors.black,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
              )
            ]
        )
    );
  }
}