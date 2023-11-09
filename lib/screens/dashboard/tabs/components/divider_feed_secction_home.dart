import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../constants.dart';

class DividerFeedSectionHome extends StatelessWidget {
  final String text;
  final double scale;
  const DividerFeedSectionHome(
      {Key? key,
        required this.text,
        required this.scale,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      alignment: Alignment.centerLeft,
      scale: scale,
      child: Container(
        padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
        decoration: const BoxDecoration(
          color: ConstantsV2.lightGrey,
        ),
        child: Text(
          text,
          style: boldoSubTextStyle,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}
