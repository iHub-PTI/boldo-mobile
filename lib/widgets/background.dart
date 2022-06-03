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
    else if(text == "SingIn_1")
      return Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: RadialGradient(
                    radius: 3,
                    center: Alignment(
                      0,
                      0,
                    ),
                    colors: <Color>[
                      ConstantsV2.singInPrimaryColor100,
                      ConstantsV2.singInPrimaryColor200,
                      ConstantsV2.singInPrimaryColor300,
                    ],
                    stops: <double>[
                      ConstantsV2.singInPrimaryStop100,
                      ConstantsV2.singInPrimaryStop200,
                      ConstantsV2.singInPrimaryStop300,
                    ]
                )
            ),
          ),
        ],
      );
    else if(text == "SingIn_2")
      return Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: RadialGradient(
                    radius: 3,
                    center: Alignment(
                      0,
                      0,
                    ),
                    colors: <Color>[
                      ConstantsV2.singInSecondaryColor100,
                      ConstantsV2.singInSecondaryColor200,
                      ConstantsV2.singInSecondaryColor300,
                    ],
                    stops: <double>[
                      ConstantsV2.singInSecondaryStop100,
                      ConstantsV2.singInSecondaryStop200,
                      ConstantsV2.singInSecondaryStop300,
                    ]
                )
            ),
          ),
        ],
      );
    else if(text == "FamilyConnect_1")
      return Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: RadialGradient(
                    radius: 3,
                    center: Alignment(
                      0,
                      0,
                    ),
                    colors: <Color>[
                      ConstantsV2.familyConnectPrimaryColor100,
                      ConstantsV2.familyConnectPrimaryColor200,
                      ConstantsV2.familyConnectPrimaryColor300,
                    ],
                    stops: <double>[
                      ConstantsV2.familyConnectPrimaryStop100,
                      ConstantsV2.familyConnectPrimaryStop200,
                      ConstantsV2.familyConnectPrimaryStop300,
                    ]
                )
            ),
          ),
        ],
      );
    else if(text == "FamilyConnect_2")
      return Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: RadialGradient(
                    radius: 3,
                    center: Alignment(
                      0,
                      0,
                    ),
                    colors: <Color>[
                      ConstantsV2.familyConnectSecondaryColor100,
                      ConstantsV2.familyConnectSecondaryColor200,
                      ConstantsV2.familyConnectSecondaryColor300,
                    ],
                    stops: <double>[
                      ConstantsV2.familyConnectSecondaryStop100,
                      ConstantsV2.familyConnectSecondaryStop200,
                      ConstantsV2.familyConnectSecondaryStop300,
                    ]
                )
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
                      ConstantsV2.familyAppBarColor100,
                      ConstantsV2.familyAppBarColor200,
                      ConstantsV2.familyAppBarColor300,
                    ],
                    stops: <double> [
                      ConstantsV2.familyAppBarStop100,
                      ConstantsV2.familyAppBarStop200,
                      ConstantsV2.familyAppBarStop300,
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
