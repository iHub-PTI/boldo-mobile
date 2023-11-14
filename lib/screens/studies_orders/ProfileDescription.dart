import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';

import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';

class ProfileDescription extends StatelessWidget {
  final Patient? patient;
  final Doctor? doctor;
  final String type;
  final double height;
  final double width;
  final bool border;
  final Color borderColor;
  final EdgeInsetsGeometry padding;

  /// show the description in the bottom of de picture or right of the picture
  final bool horizontalDescription;

  ProfileDescription({this.patient,
    this.doctor,
    required this.type,
    this.horizontalDescription = false,
    this.height = 54,
    this.width = 54,
    this.border = true,
    this.borderColor = ConstantsV2.orange,
    this.padding = const EdgeInsets.all(16)
  });

  @override
  Widget build(BuildContext context) {

    List<Widget> elements = [
      // profile picture
      ImageViewTypeForm(
        height: height,
        width: width,
        border: border,
        url: type=='doctor'? doctor?.photoUrl : patient?.photoUrl,
        gender: type=='doctor'? doctor?.gender : patient?.gender,
        borderColor: borderColor,
        isPatient: type=='doctor',
        elevation: 0,
      ),
      if(doctor != null || patient != null)
        const SizedBox(height: 10, width: 10,),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(doctor != null || patient != null)
          // first name and last name
            Flexible(child: Text(
                doctor != null
                    ? doctor!.gender == 'female'
                    ? 'Dra. ${toLowerCase(doctor!.givenName!).trim().split(RegExp(' +'))[0]} ${toLowerCase(doctor!.familyName!).trim().split(RegExp(' +'))[0]}'
                    : 'Dr. ${toLowerCase(doctor!.givenName!).trim().split(RegExp(' +'))[0]} ${toLowerCase(doctor!.familyName!).trim().split(RegExp(' +'))[0]}'
                    : patient != null
                    ? '${toLowerCase(patient!.givenName!).trim().split(RegExp(' +'))[0]} ${toLowerCase(patient!.familyName!).trim().split(RegExp(' +'))[0]}'
                    : '',
                style:
                boldoCorpMediumTextStyle.copyWith(color: Colors.black)
            ),),
          // decription
          if(doctor != null || patient != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  doctor != null
                      ? 'Médico'
                      : patient != null
                      ? 'Paciente'
                      : '',
                  style: boldoCorpMediumTextStyle.copyWith(color: Constants.otherColor100),
                ),
              ],
            ),
        ],
      ),
    ];

    Widget child = horizontalDescription? Row(
      children: elements,
    ): Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: elements,
    );

    return Flexible(
      child: Container(
        padding: padding,
        child: child,
      ),
    );
  }
}
