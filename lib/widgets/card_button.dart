import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {

  final Function? function;
  final Widget child;
  final ShapeDecoration? decoration;

  const CardButton({
    this.function,
    required this.child,
    this.decoration = const ShapeDecoration(
      color: ConstantsV2.veryLightOrange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(6)),
      ),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      textStyle: bigButton,
      child: InkWell(
        onTap: ()=> function?.call(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }



}