import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:email_validator/email_validator.dart';

import '../../constants.dart';


class SignUpBasicInfo extends StatelessWidget {
  const SignUpBasicInfo({Key? key}) : super(key: key);

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
                colors: <Color> [
                  ConstantsV2.primaryColor100,
                  ConstantsV2.primaryColor200,
                  ConstantsV2.primaryColor300,
                ],
                stops: <double> [
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
                  image: AssetImage('assets/images/register_background.png')
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: SvgPicture.asset('assets/icon/logo_text.svg'),
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Nombre y Apellido"),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Email"),
                  validator: (value) => EmailValidator.validate(value!) ? null : 'Ingrese un correo válido',
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Fecha de nacimiento",
                    suffixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: SvgPicture.asset(
                        'assets/icon/calendar.svg',
                        color: Constants.primaryColor100,
                        height: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton (
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => SearchingHelper()),
                      // );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('siguiente'),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SvgPicture.asset('assets/icon/arrow-right.svg'),
                        )
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      primary: ConstantsV2.buttonPrimaryColor100,
                    ),
                  ),
                ),
              ],
            ),
          )
        ]
      )

    );
  }
}