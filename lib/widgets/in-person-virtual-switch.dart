import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';

class VirtualInPersonSwitch extends StatefulWidget {
  final Function(String text) switchCallbackResponse;
  const VirtualInPersonSwitch({Key? key, required this.switchCallbackResponse})
      : super(key: key);
  @override
  _VirtualInPersonSwitchState createState() => _VirtualInPersonSwitchState();
}

const double width = 300.0;
const double height = 40.0;
const double loginAlign = -1;
const double signInAlign = 1;
const Color selectedColor = ConstantsV2.primaryRegular;
const Color normalColor = ConstantsV2.blueDark;

class _VirtualInPersonSwitchState extends State<VirtualInPersonSwitch> {
  double? xAlign;
  Color? loginColor;
  Color? signInColor;

  @override
  void initState() {
    super.initState();
    xAlign = loginAlign;
    loginColor = selectedColor;
    signInColor = normalColor;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          color: ConstantsV2.grayLightest,
          borderRadius: BorderRadius.all(
            Radius.circular(100.0),
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(xAlign!, 0),
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: width * 0.5,
                height: height,
                decoration: BoxDecoration(
                  color: ConstantsV2.primaryLightAndClear,
                  borderRadius: BorderRadius.horizontal(
                    left: xAlign == -1? Radius.circular(100.0) : Radius.zero,
                    right: !(xAlign == -1)? Radius.circular(100.0) : Radius.zero,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  xAlign = loginAlign;
                  loginColor = selectedColor;
                  signInColor = normalColor;
                  widget.switchCallbackResponse('A');
                });
              },
              child: Align(
                alignment: const Alignment(-1, 0),
                child: Container(
                  width: width * 0.5,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.person,
                          color: loginColor,
                        ),
                      ),
                      Text(
                        'En Persona',
                        style: TextStyle(
                          color: loginColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  xAlign = signInAlign;
                  signInColor = selectedColor;
                  loginColor = normalColor;
                  widget.switchCallbackResponse('V');
                });
              },
              child: Align(
                alignment: const Alignment(1, 0),
                child: Container(
                  width: width * 0.5,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SvgPicture.asset(
                          'assets/icon/video.svg',
                          semanticsLabel: 'video Icon',
                          color: signInColor,
                        ),
                      ),
                      Text(
                        'Remoto',
                        style: TextStyle(
                          color: signInColor,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
