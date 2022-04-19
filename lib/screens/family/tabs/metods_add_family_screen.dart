import 'package:boldo/constants.dart';
import 'package:boldo/screens/register/dni_register.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'family_register_account.dart';

class FamilyMetodsAdd extends StatelessWidget {
  const FamilyMetodsAdd({Key? key}) : super(key: key);

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          "Boldo te permite agregar y gestionar los perfiles de "
                              "salud de tus seres queridos.",
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
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            "Elegí uno de los siguiente métodos",
                            style: boldoCorpMediumBlackTextStyle.copyWith(
                              color: ConstantsV2.activeText
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: ConstantsV2.lightAndClear.withOpacity(0.80),
                          child: InkWell(
                            onTap: () {
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/qrcode.svg',
                                    color: ConstantsV2.activeText,
                                  ),
                                  const SizedBox(width: 10,),
                                  Flexible(
                                    child: Text(
                                      "Si la persona a la que querés agregar ya "
                                          "cuenta con un perfil en Boldo, pedile "
                                          "que genere una QR dentro de la app. "
                                          "Escaneá y listo.",
                                      style: boldoCorpMediumTextStyle.copyWith(
                                        color: ConstantsV2.activeText,
                                      ),
                                    )
                                  )
                                ],
                              )
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: ConstantsV2.lightAndClear.withOpacity(0.80),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => DniFamilyRegister()
                              )
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/identification.svg',
                                    color: ConstantsV2.activeText,
                                  ),
                                  const SizedBox(width: 10,),
                                  Flexible(
                                    child: Text(
                                      "Si la persona aún no cuenta con un "
                                          "perfil, deberás realizar el proceso "
                                          "de verificación de identidad.",
                                      style: boldoCorpMediumTextStyle.copyWith(
                                        color: ConstantsV2.activeText,
                                      ),
                                    )
                                  )
                                ],
                              )
                            ),
                          ),
                        ),
                      ],
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