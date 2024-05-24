import 'package:boldo/app_config.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/screens/family/tabs/QR_scanner.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/background.dart';
import 'package:boldo/widgets/information_card.dart';
import 'package:boldo/widgets/service_offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FamilyMetodsAdd extends StatelessWidget {
  const FamilyMetodsAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(text: "linkFamily"),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButtonLabel(
                        iconType: BackIcon.backArrow,
                        iconColor: BackIcon.backClose.iconColor,
                        labelText: 'Mi Familia',
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 26,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          "Boldo te permite agregar y gestionar los perfiles de "
                          "salud de tus seres queridos.",
                          style: boldoSubTextMediumStyle.copyWith(
                            color: ConstantsV2.activeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Elegí uno de los siguiente métodos",
                            style: boldoCorpMediumBlackTextStyle.copyWith(
                              color: ConstantsV2.activeText,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        InformationCard(
                          child: InkWell(
                            onTap: () async {
                              // enable access
                              if (appConfig.ACCESS_ADD_DEPENDENT_QR)
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QRScanner(),
                                  ),
                                );
                              else
                                serviceOfflinePopUp(context: context);
                            },
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/qrcode.svg',
                                    color: ConstantsV2.activeText,
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Si la persona a la que querés agregar ya cuenta con un perfil en Boldo, pedile que genere una QR dentro de la app. Escaneá y listo.",
                                      style: boldoCorpMediumTextStyle.copyWith(
                                        color: ConstantsV2.activeText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        InformationCard(
                          child: InkWell(
                            onTap: () {
                              // enable access
                              if (appConfig.ACCESS_ADD_DEPENDENT_CI)
                                Navigator.pushNamed(
                                    context, '/familyDniRegister');
                              else
                                serviceOfflinePopUp(context: context);
                            },
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/identification.svg',
                                    color: ConstantsV2.activeText,
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Si la persona aún no cuenta con un perfil, deberás realizar el proceso de verificación de identidad.",
                                      style: boldoCorpMediumTextStyle.copyWith(
                                        color: ConstantsV2.activeText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        InformationCard(
                          child: InkWell(
                            onTap: () {
                              // enable access
                              if (appConfig.ACCESS_ADD_DEPENDENT_WITHOUT_CI)
                                Navigator.pushNamed(
                                  context,
                                  '/familyWithoutDniRegister',
                                );
                              else
                                serviceOfflinePopUp(context: context);
                            },
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/form.svg',
                                    color: ConstantsV2.activeText,
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Si la persona aún no cuenta con un perfil y tampoco con cédula de identidad, deberás completar el siguiente formulario.",
                                      style: boldoCorpMediumTextStyle.copyWith(
                                        color: ConstantsV2.activeText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.only(bottom: 26, right: 16),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(width: 1, color: ConstantsV2.orange),
                    ),
                    child: OutlinedButtonTheme(
                      data: boldoTheme.outlinedButtonTheme,
                      child: const Text(
                        'Lo haré más tarde',
                        style: TextStyle(fontFamily: 'Montserrat'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
