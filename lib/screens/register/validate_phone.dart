import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';

class ValidateUserPhone extends StatefulWidget {

  final String phoneNumber;
  final String code;

  ValidateUserPhone({Key? key,
    required this.phoneNumber,
    required this.code,
  }) : super(key: key);

  @override
  State<ValidateUserPhone> createState() => _ValidateUserPhoneState(code, phoneNumber);
}

class _ValidateUserPhoneState extends State<ValidateUserPhone> {
  final String code;
  final String phoneNumber;
  _ValidateUserPhoneState(this.code, this.phoneNumber, );


  @override
  Widget build(BuildContext context) {
    print(code);
    return Scaffold(
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration( // Background linear gradient
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: <Color>[
                      ConstantsV2.primaryColor100,
                      ConstantsV2.primaryColor200,
                      ConstantsV2.primaryColor300,
                    ],
                    stops: <double>[
                      ConstantsV2.primaryStop100,
                      ConstantsV2.primaryStop200,
                      ConstantsV2.primaryStop300,
                    ]
                )
            ),
          ),
          Opacity(
            opacity: 0.2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                        'assets/images/register_phone_background.png')
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: SvgPicture.asset(
                        'assets/icon/logo_text.svg',
                        semanticsLabel: 'BOLDO Logo',
                        height: 100,
                        width: 100,
                      )),
                  SizedBox(
                    height: 70,
                  ),
                  Text(
                    'confirmá tu número\n'
                        'de teléfono',
                    textAlign: TextAlign.center,
                    style: boldoSubTextStyle.copyWith(fontSize: 25),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 70,
                          height: 70,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.white,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                contentPadding:
                                EdgeInsetsDirectional.only(top: 10.0),
                              ),
                            ),
                          )),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                          width: 70,
                          height: 70,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.white,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                contentPadding:
                                EdgeInsetsDirectional.only(top: 10.0),
                              ),
                            ),
                          )),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                          width: 70,
                          height: 70,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.white,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                contentPadding:
                                EdgeInsetsDirectional.only(top: 10.0),
                              ),
                            ),
                          )),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                          width: 70,
                          height: 70,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.white,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                contentPadding:
                                EdgeInsetsDirectional.only(top: 10.0),
                              ),
                            ),
                          )),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        'Enviamos un código de confirmación al\n'
                            '+595 986 776 837. Escriba el código arriba.',
                        style: boldoSubTextStyle.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  OutlineButton(
                    child: Text(
                      "Reenviar código",
                    ),
                    onPressed: () {
                      print('tapped');
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Usar otro número de teléfono',
                        style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            color: ConstantsV2.enableBorded)),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}