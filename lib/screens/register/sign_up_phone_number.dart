import 'dart:math';

import 'package:boldo/screens/register/validate_phone.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../constants.dart';


class SignUpPhoneInfo extends StatefulWidget {
  const SignUpPhoneInfo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpPhoneInfoState();
}

class _SignUpPhoneInfoState extends State<SignUpPhoneInfo> {

  _SignUpPhoneInfoState({Key? key});

  FocusNode? focusPhone;
  FocusNode? focusPassword;
  FocusNode? focusConfirmPassword;

  bool _hasPhoneLengthError = false;
  GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey<FormState> _formPasswordKey = GlobalKey();
  GlobalKey<FormState> _formPhoneKey = GlobalKey();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var phoneController = TextEditingController();

  @override
  void initState(){
    super.initState();
    focusPhone = FocusNode();
    focusPassword = FocusNode();
    focusConfirmPassword = FocusNode();
  }

  @override
  void dispose(){
    focusPhone!.dispose();
    focusPassword!.dispose();
    focusConfirmPassword!.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Material(
        child: Stack(
            children: [
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
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(42.0),
                        child: SvgPicture.asset('assets/icon/logo_text.svg'),
                      ),
                      phoneForm(),
                      const SizedBox(
                        height: 22,
                      ),

                      passwordForm(),
                      const SizedBox(
                        height: 40,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => SearchingHelper()),
                            // );
                            // _formPhoneKey.currentState.widget.child.
                            focusPhone!.unfocus();
                            focusPassword!.unfocus();
                            focusConfirmPassword!.unfocus();
                            // Await for unFocus for all forms
                            String code;
                            Future.delayed(const Duration(seconds: 1), () => {
                              if(_formKey.currentState!.validate()){
                                print("valido"),
                                code = "${Random().nextInt(10000)}".padLeft(4, '0'),
                                print(code),
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => ValidateUserPhone(phoneNumber: phoneController.value.text, code: code )
                                  )
                                )
                              //_formPhoneKey.currentState.h
                              }else{
                                print("Error")
                              }
                            });

                          },
                          child: Container(
                            constraints: const BoxConstraints(
                                maxWidth: 142, maxHeight: 48),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'siguiente',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Montserrat',
                                    color: ConstantsV2.primaryColor,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: SvgPicture.asset(
                                      'assets/icon/arrow-right.svg'),
                                )
                              ],
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            primary: ConstantsV2.buttonPrimaryColor100,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "¿Ya tenés cuenta?"
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginWebViewHelper()),
                            ),
                            child: const Text('iniciar sesión',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                    color: ConstantsV2.buttonPrimaryColor100)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ]
        )
    );
  }

  Widget phoneForm(){
    return TextFormField(
      controller: phoneController,
      maxLength: 13,
      autofocus: true,
      focusNode: focusPhone,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: "Número de teléfono",
        hintText: 'Example: +595981654321',
      ),
      validator: (value) {
        if(value!.isEmpty) {
          return 'ingrese un número de teléfono';
        } else {
          RegExp regExp = RegExp(r'(^\+[0-9]{1,12}$)');
          if( !regExp.hasMatch(value) ){
            return 'Ingrese un número válido';
          }
          if( !focusPhone!.hasFocus && value.length < 13 ){
            return 'Ingrese un número válido';
          }
        }
      },
    );
  }

  Widget passwordForm(){
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                autofocus: true,
                controller: passwordController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  suffixIcon: SvgPicture.asset('assets/icon/checkCircle.svg'),
                ),
                validator: (value) {
                  if(value!.isEmpty) {
                    return 'Ingrese la contraseña';
                  }
                },
              ),
              const SizedBox(
                height: 22,
              ),
              TextFormField(
                controller: confirmPasswordController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Repetir contraseña",
                  suffixIcon: SvgPicture.asset('assets/icon/checkCircle.svg', width: 2, height: 2,),
                ),
                validator: (value) {
                  if(value!.isEmpty) {
                    return 'Ingrese la contraseña';
                  } else {
                    if(passwordController.value.text != value){
                      return 'No coincide las contraseñas';
                    }
                  }
                },
              ),
            ]
    );
  }


}

