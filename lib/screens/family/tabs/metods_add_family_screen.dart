import 'package:boldo/constants.dart';
import 'package:boldo/screens/family/tabs/QR_scanner.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class FamilyMetodsAdd extends StatelessWidget {
  const FamilyMetodsAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: OutlinedButtonTheme(
              data: boldoTheme.outlinedButtonTheme,
              child: const Text(
                'lo haré más tarde',
                style: TextStyle(fontFamily: 'Montserrat'),
              )),
          style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1.0, color: ConstantsV2.orange)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Stack(
        children: [
          const Background(text: "linkFamily"),
          SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
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
                      Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height >= 600
                                ? MediaQuery.of(context).size.height*0.01
                                : 0,
                            left: 16,
                            right: 16,
                            bottom: 16
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                "Boldo te permite agregar y gestionar los perfiles de "
                                    "salud de tus seres queridos.",
                                style: boldoSubTextMediumStyle.copyWith(
                                    color: ConstantsV2.activeText),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height >= 600
                                ? MediaQuery.of(context).size.height*0.02
                                : 0,
                            right: 16.0,
                            left: 16.0
                        ),
                        child: Text(
                          "Elegí uno de los siguiente métodos",
                          style: boldoCorpMediumBlackTextStyle.copyWith(
                              color: ConstantsV2.activeText),
                        ),
                      ),
                      Card(
                        margin:  EdgeInsets.only(
                            top: 16,
                            right: 16,
                            left: 16,
                            bottom: MediaQuery.of(context).size.height >= 600
                                ? MediaQuery.of(context).size.height*0.01
                                : 0
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: ConstantsV2.lightAndClear.withOpacity(0.80),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => QRScanner()),
                            );
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
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: Text(
                                        "Si la persona a la que querés agregar ya cuenta con un perfil en Boldo, pedile que genere una QR dentro de la app. Escaneá y listo.",
                                        style: boldoCorpMediumTextStyle.copyWith(
                                          color: ConstantsV2.activeText,
                                        ),
                                      ))
                                ],
                              )),
                        ),
                      ),
                      Card(
                        margin:  EdgeInsets.only(
                            top: 16,
                            right: 16,
                            left: 16,
                            bottom: MediaQuery.of(context).size.height >= 600
                                ? MediaQuery.of(context).size.height*0.01
                                : 0
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: ConstantsV2.lightAndClear.withOpacity(0.80),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/familyDniRegister');
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
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: Text(
                                        "Si la persona aún no cuenta con un perfil, deberás realizar el proceso de verificación de identidad.",
                                        style: boldoCorpMediumTextStyle.copyWith(
                                          color: ConstantsV2.activeText,
                                        ),
                                      ))
                                ],
                              )),
                        ),
                      ),
                      Card(
                        margin:  EdgeInsets.only(
                            top: 16,
                            right: 16,
                            left: 16,
                            bottom: MediaQuery.of(context).size.height >= 600
                                ? MediaQuery.of(context).size.height*0.01
                                : 0
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: ConstantsV2.lightAndClear.withOpacity(0.80),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/familyWithoutDniRegister');
                          },
                          child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/form.svg',
                                    color: ConstantsV2.activeText,
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
                                      ))
                                ],
                              )
                          ),
                        ),
                      ),
                    ]
                ),
              ),
            ),
          ),
        ]
      )
    );
  }
}