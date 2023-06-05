import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import 'package:boldo/constants.dart';

class EmptyStateV2 extends StatelessWidget {
  final String? picture;
  final String? textTop;
  final String? titleBottom;
  final String? textBottom;
  final EdgeInsets paddingButtonPicture;
  const EmptyStateV2({
    Key? key,
    this.picture,
    this.textTop,
    this.textBottom,
    this.titleBottom,
    this.paddingButtonPicture = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          children: [
            Text(
              textTop ?? '',
              style: boldoCorpSmallTextStyle.copyWith(
                color: ConstantsV2.darkBlue,
              ),
            ),
            picture != null ?Container(
              padding: const EdgeInsets.only(left: 1, right: 1),
              child: SvgPicture.asset(
                'assets/icon/$picture',
                fit: BoxFit.cover,
              ),
            ): Container(),
            if(picture != null)
            Container(
              padding: paddingButtonPicture,
            ),
            titleBottom != null
              ? Text(
                titleBottom!,
                style: boldoTitleBlackTextStyle.copyWith(
                  fontSize: 20,
                )
              )
              : Container(),
            SizedBox(height: titleBottom != null ? 10 : 0),
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
