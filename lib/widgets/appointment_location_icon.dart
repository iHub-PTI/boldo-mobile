import 'package:boldo/constants.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget locationType(AppointmentType? appointmentType) {

  Widget icon;

  switch (appointmentType){
    case AppointmentType.InPerson:
      icon = Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          child: SvgPicture.asset(
            'assets/icon/location_marker.svg',
            color: ConstantsV2.veryLightBlue,
          ),
        ),
      );
      break;
    case AppointmentType.Virtual:
      icon = Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            child: SvgPicture.asset(
              'assets/icon/watch-later.svg',
              color: ConstantsV2.veryLightBlue,
            ),
          )
      );
      break;
    case null:
      icon = const Icon(Icons.error);
      break;
  }

  return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
      ),
      child: icon
  );
}