import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:flutter/cupertino.dart';

Widget header(String? text, String? patientText,
    {double? height,
      double? width,
      bool border = true,
      Color? borderColor = ConstantsV2.orange,
      EdgeInsetsGeometry? padding = const EdgeInsets.all(16)}
    ) {
  return Container(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        prefs.getBool(isFamily) ?? false ?
        Flexible(child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                    text: '$patientText de ',
                    style: boldoScreenTitleTextStyle.copyWith(
                        color: ConstantsV2.inactiveText
                    ),
                    children: [
                      TextSpan(
                        text: '${patient.givenName} ${patient.familyName}',
                        style: boldoScreenTitleTextStyle.copyWith(
                          color: ConstantsV2.green,
                        ),
                      ),
                    ]
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )):
        Flexible(
          child: Text(
            text?? "Cacecera",
            style: boldoScreenTitleTextStyle.copyWith(color: ConstantsV2.activeText),
          ),
        ),
        ImageViewTypeForm(
          height: height?? 60,
          width: width?? 60,
          border: border,
          url: patient.photoUrl,
          gender: patient.gender,
          borderColor: borderColor,
          elevation: 0,
        ),
      ],
    ),
  );
}