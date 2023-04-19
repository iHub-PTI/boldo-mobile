import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ButtonActionHelper extends StatelessWidget {
  final String title;
  final String svgPath;
  final Function() onTapAction;
  const ButtonActionHelper(
      {Key? key,
      required this.title,
      required this.onTapAction,
      this.svgPath = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      child: ElevatedButton(
          onPressed: () => onTapAction(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title),
              svgPath != ''
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SvgPicture.asset('assets/icon/$svgPath.svg'),
                    )
                  : Container()
            ],
          ),
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            primary: Constants.otherColor400,
          )),
    );
  }
}
