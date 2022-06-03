import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import 'package:boldo/constants.dart';

class EmptyStateV2 extends StatelessWidget {
  final String picture;
  final String? textTop;
  final String? textBottom;
  const EmptyStateV2(
      {Key? key, required this.picture, this.textTop, this.textBottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        child: Column(
          children: [
            Text(
              textTop ?? '',
              style: boldoCorpSmallTextStyle.copyWith(
                color: ConstantsV2.darkBlue,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 1, right: 1),
              child: SvgPicture.asset(
                'assets/icon/$picture',
                fit: BoxFit.cover,
              ),
            ),
            Text(
              textBottom ?? '',
              style: boldoCorpMediumTextStyle.copyWith(
                color: ConstantsV2.activeText,
              ),
            ),
          ]
        )
      )
    );
  }
}
