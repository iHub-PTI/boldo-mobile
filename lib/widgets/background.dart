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
    else if(text == "BookingConfirmFinal")
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
                    image: AssetImage('assets/images/background_booking_confirm_final.png')
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

class BackgroundRadialGradientTransition extends StatefulWidget {
  final List<Color> initialColors;
  final List<Color> finalColors;
  final List<double> initialStops;
  final List<double> finalStops;
  final double initialRadius;
  final double finalRadius;
  final AnimationController animationController;
  const BackgroundRadialGradientTransition({
    Key? key,
    required this.initialColors,
    required this.finalColors,
    required this.initialStops,
    required this.finalStops,
    this.initialRadius = 1,
    this.finalRadius = 1,
    required this.animationController,
  }) : super(key: key);

  @override
  _BackgroundColorTransitionState createState() => _BackgroundColorTransitionState();
}

class _BackgroundColorTransitionState extends State<BackgroundRadialGradientTransition>{

  List<Animation<Color?>> animationColors = [];

  List<Animation<double?>> animationStops = [];

  late Animation<double?> _radiusTween;

  @override
  void initState() {

    // initialize animation duration
    widget.animationController..addListener(() {
      // change screen with animation
      setState(() {

      });
    });

    //initialize radius value
    _radiusTween = Tween<double?>(begin: widget.initialRadius, end: widget.finalRadius).animate(
        CurvedAnimation(parent: widget.animationController, curve: Curves.linear)
    );

    //initialize colors values
    widget.initialColors.asMap().entries.forEach((element) {
      animationColors.add(ColorTween(
          begin: element.value,
          end: widget.finalColors[element.key])
          .animate(
          CurvedAnimation(parent: widget.animationController, curve: Curves.linear)
      ));
    });

    //initialize stops values
    widget.initialStops.asMap().entries.forEach((element) {
      animationStops.add(Tween<double?>(
          begin: element.value,
          end: widget.finalStops[element.key]
      ).animate(
          CurvedAnimation(parent: widget.animationController, curve: Curves.linear)
      ));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: RadialGradient(
              radius: _radiusTween.value?? 1,
              center: const Alignment(
                0,
                0,
              ),
              colors: animationColors.map((e) => e.value?? ConstantsV2.primaryColor).toList(),
              stops: animationStops.map((e) => e.value?? 1).toList()
          )
      ),
    );
  }

}

class BackgroundLinearGradientTransition extends StatefulWidget {
  final List<Color> initialColors;
  final List<Color> finalColors;
  final List<double> initialStops;
  final List<double> finalStops;
  final Alignment begin;
  final Alignment end;
  final AnimationController animationController;
  const BackgroundLinearGradientTransition({
    Key? key,
    required this.initialColors,
    required this.finalColors,
    required this.initialStops,
    required this.finalStops,
    this.begin = Alignment.bottomCenter,
    this.end = Alignment.topCenter,
    required this.animationController,
  }) : super(key: key);

  @override
  _BackgroundLinearColorTransitionState createState() => _BackgroundLinearColorTransitionState();
}

class _BackgroundLinearColorTransitionState extends State<BackgroundLinearGradientTransition>{

  List<Animation<Color?>> animationColors = [];

  List<Animation<double?>> animationStops = [];

  @override
  void initState() {

    // initialize animation duration
    widget.animationController..addListener(() {
      // change screen with animation
      setState(() {

      });
    });

    //initialize colors values
    widget.initialColors.asMap().entries.forEach((element) {
      animationColors.add(ColorTween(
          begin: element.value,
          end: widget.finalColors[element.key])
          .animate(
          CurvedAnimation(parent: widget.animationController, curve: Curves.linear)
      ));
    });

    //initialize stops values
    widget.initialStops.asMap().entries.forEach((element) {
      animationStops.add(Tween<double?>(
          begin: element.value,
          end: widget.finalStops[element.key]
      ).animate(
          CurvedAnimation(parent: widget.animationController, curve: Curves.linear)
      ));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: widget.begin,
            end: widget.end,
          colors: animationColors.map((e) => e.value?? ConstantsV2.primaryColor).toList(),
          stops: animationStops.map((e) => e.value?? 1).toList(),
        ),
      ),
    );
  }

}