import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:flutter/cupertino.dart';

Widget header(String? text, String? patientText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      prefs.getBool(isFamily) ?? false ?
      Flexible(child: Row(
        children: [
          Text(
            '$patientText de ',
            style: boldoScreenTitleTextStyle.copyWith(
                color: ConstantsV2.inactiveText),
          ),
          Expanded(
            child: Container(
              child: Text(
                '${patient.givenName} ${patient.familyName}',
                style: boldoScreenTitleTextStyle.copyWith(
                    color: ConstantsV2.green
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      )):
      Text(
        text?? "Cacecera",
        style: boldoScreenTitleTextStyle.copyWith(color: ConstantsV2.activeText),
      ),
      ImageViewTypeForm(
        height: 60,
        width: 60,
        border: true,
        url: patient.photoUrl,
        gender: patient.gender,
      ),
    ],
  );
}