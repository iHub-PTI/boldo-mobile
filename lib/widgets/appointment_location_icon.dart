import 'package:boldo/constants.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget locationType(AppointmentType? appointmentType) {

  Widget icon;

  switch (appointmentType){
    case AppointmentType.InPerson:
      icon = Container(
        child: SvgPicture.asset(
          'assets/icon/location_marker.svg',
          color: ConstantsV2.inactiveText,
        ),
      );
      break;
    case AppointmentType.Virtual:
      icon = Container(
        child: SvgPicture.asset(
          'assets/icon/watch-later.svg',
          color: ConstantsV2.inactiveText,
        ),
      );
      break;
    case null:
      icon = const Icon(Icons.error);
      break;
  }

  return Container(
      child: icon
  );
}