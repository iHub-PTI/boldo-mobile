import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

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
  bool hasError = false;
  final TextEditingController pinController = TextEditingController();

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 60.0),
                        child: SvgPicture.asset(
                          'assets/icon/logo_text.svg',
                          semanticsLabel: 'BOLDO Logo',
                          height: 100,
                          width: 100,
                        )
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    Text(
                      'confirmá tu número\n'
                          'de teléfono',
                      textAlign: TextAlign.center,
                      style: boldoSubTextStyle.copyWith(fontSize: 25),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    PinCodeTextField(
                      autofocus: false,
                      controller: pinController,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      pinBoxWidth: 48,
                      pinBoxHeight: 53,
                      defaultBorderColor: Colors.transparent,
                      pinBoxRadius: 8,
                      wrapAlignment: WrapAlignment.spaceAround,
                      hasTextBorderColor: Colors.transparent,
                      hasError: hasError,
                      pinTextStyle: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Montserrat',
                      ),
                      onDone: (text){
                        setState(() {
                          if(text!=code){
                            hasError = true;
                            print("Error");
                          }else{
                            hasError = false;
                          }
                        });
                        print("DONE $text");
                      },
                    ),
                    Visibility(
                      child: const Text(
                        "Incorrecto"
                      ),
                      visible: hasError,
                    ),
                    /*Row(
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
                                maxLength: 1,
                                decoration: const InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  contentPadding:
                                  EdgeInsetsDirectional.only(top: 10.0),
                                ),
                              ),
                            )),
                        const SizedBox(
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
                                maxLength: 1,
                                decoration: const InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  contentPadding:
                                  EdgeInsetsDirectional.only(top: 10.0),
                                ),
                              ),
                            )),
                        const SizedBox(
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
                                maxLength: 1,
                                decoration: const InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  contentPadding:
                                  EdgeInsetsDirectional.only(top: 10.0),
                                ),
                              ),
                            )),
                        const SizedBox(
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
                                maxLength: 1,
                                decoration: const InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  contentPadding:
                                  EdgeInsetsDirectional.only(top: 10.0),
                                ),
                              ),
                            )),
                      ],
                    ),*/
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          'Enviamos un código de confirmación al\n'
                              '$phoneNumber. Escriba el código arriba.',
                          style: boldoSubTextStyle.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: const StadiumBorder(),
                          side: const BorderSide(
                              color: ConstantsV2.buttonPrimaryColor100
                          )
                      ),
                      child: const Text(
                        "Reenviar código",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Montserrat',
                          color: ConstantsV2.buttonPrimaryColor100,
                        ),
                      ),
                      onPressed: () {
                        print('tapped');
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Usar otro número de teléfono',
                          style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: ConstantsV2.enableBorded)),
                    ),
                  ],
                ),
              )
            ),
          ),
        ]));
  }
}