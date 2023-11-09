import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {

  final Widget? child;
  final Function()? onTap;

  InfoCard({
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context){
    return Material(
      color: ConstantsV2.lightest,
      shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
        onTap: onTap,
      ),
    );
  }

}