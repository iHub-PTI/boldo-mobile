import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';

class DividerFeedSectionHome extends StatelessWidget {
  final String text;
  final double height;
  const DividerFeedSectionHome(
      {Key? key,
        required this.text,
        required this.height,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Container(
          width: double.maxFinite ,
          height: height,
          padding: const EdgeInsetsDirectional.all(16),
          decoration: const BoxDecoration(
            color: ConstantsV2.lightGrey,
          ),
          child: Text(
            text,
            style: boldoSubTextStyle,
          ),
        ),
    );
  }
}
