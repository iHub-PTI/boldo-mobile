import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget{

  const InfoCard({

    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
          8
      ),
      decoration: ShapeDecoration(
        color: ConstantsV2.lightAndClear.withOpacity(0.80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: child,
    );
  }

}