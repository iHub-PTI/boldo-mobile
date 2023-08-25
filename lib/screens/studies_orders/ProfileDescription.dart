import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Patient.dart';

import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileDescription extends StatelessWidget {
  final Patient? patient;
  final Doctor? doctor;
  final String type;

  ProfileDescription({this.patient, this.doctor, required this.type});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // profile picture
            ClipOval(
              child: SizedBox(
                width: 60,
                height: 60,
                child: type == "doctor"
                    ? doctor?.photoUrl == null
                    ? SvgPicture.asset(
                    doctor?.gender == "female"
                        ? 'assets/images/femaleDoctor.svg'
                        : 'assets/images/maleDoctor.svg',
                    fit: BoxFit.cover)
                    : CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: doctor!.photoUrl!,
                  progressIndicatorBuilder:
                      (context, url, downloadProgress) => Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: LinearProgressIndicator(
                      value: downloadProgress.progress,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor400),
                      backgroundColor: Constants.primaryColor600,
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                )
                    : patient?.photoUrl == null
                    ? SvgPicture.asset(
                    patient?.gender == "female"
                        ? 'assets/images/femalePatient.svg'
                        : 'assets/images/malePatient.svg',
                    fit: BoxFit.cover)
                    : CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: patient!.photoUrl!,
                  progressIndicatorBuilder:
                      (context, url, downloadProgress) => Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: LinearProgressIndicator(
                      value: downloadProgress.progress,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor400),
                      backgroundColor: Constants.primaryColor600,
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 10,),
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
      ),
    );
  }
}
