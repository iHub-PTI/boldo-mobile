import 'package:flutter/material.dart';

import '../constants.dart';

class Background extends StatelessWidget {
  final String text;
  const Background(
      {Key? key, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(text == "menu")
      return Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
                gradient: RadialGradient(
                    radius: 6,
                    center: Alignment(
                      1.80,
                      3.20,
                    ),
                    colors: <Color>[
                      ConstantsV2.patientAppBarColor100,
                      ConstantsV2.patientAppBarColor200,
                      ConstantsV2.patientAppBarColor300,
                    ],
                    stops: <double>[
                      ConstantsV2.patientAppBarStop100,
                      ConstantsV2.patientAppBarStop200,
                      ConstantsV2.patientAppBarStop300,
                    ]
                )
            ),
          ),
        ],
      );
    else if(text == "family")
      return Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: ConstantsV2.lightGrey
            ),
          ),
        ],
      );
    else if(text == "linkFamily")
      return Stack(
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
        ],
      );
    else
      return Stack(
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
                    image: AssetImage('assets/images/hero_background.png')
                ),
              ),
            ),
          ),
        ],
      );
  }
}
