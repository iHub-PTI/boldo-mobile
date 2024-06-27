import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ButtonActionHelper extends StatelessWidget {
  const ButtonActionHelper({
    required this.title,
    required this.onTapAction,
    super.key,
    this.svgPath = '',
  });
  final String title;
  final String svgPath;
  final Function() onTapAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: onTapAction,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: Constants.otherColor400,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            if (svgPath != '')
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SvgPicture.asset('assets/icon/$svgPath.svg'),
              )
            else
              Container(),
          ],
        ),
      ),
    );
  }
}
