import 'package:boldo/constants.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget showAppointmentTypeIcon(AppointmentType? appointmentType) {

  Widget icon;

  switch (appointmentType){
    case AppointmentType.InPerson:
      icon = Container(
        width: 10,
        height: 10,
        child: SvgPicture.asset(
          'assets/icon/person.svg',
          color: Constants.primaryColor500,
        ),
      );
      break;
    case AppointmentType.Virtual:
      icon = Container(
        width: 10,
        height: 10,
        child: SvgPicture.asset(
          'assets/icon/video.svg',
          color: Constants.secondaryColor500,
        ),
      );
      break;
    case null:
    default:
      icon = const Icon(Icons.error);
      break;
  }

  return Container(
    child: icon
  );
}