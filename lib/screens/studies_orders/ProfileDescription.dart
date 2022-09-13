
import 'package:boldo/constants.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/StudyOrder.dart';
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // profile picture
          ClipOval(
            child: SizedBox(
              width: 60,
              height: 60,
              child: type == "doctor"
                ? doctor!.photoUrl == null 
                  ? SvgPicture.asset(
                    doctor!.gender == "female"
                      ? 'assets/images/femaleDoctor.svg'
                      : 'assets/images/maleDoctor.svg',
                    fit: BoxFit.cover
                  )
                  : CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: doctor!.photoUrl!,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: LinearProgressIndicator(
                          value: downloadProgress.progress,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Constants.primaryColor400
                          ),
                          backgroundColor:Constants.primaryColor600,
                        ),
                      ),
                    errorWidget: (context, url,  error) => const Icon(Icons.error),
                  )
                : patient!.photoUrl == null 
                  ? SvgPicture.asset(
                    patient!.gender == "female"
                      ? 'assets/images/femalePatient.svg'
                      : 'assets/images/malePatient.svg',
                    fit: BoxFit.cover
                  )
                  : CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: patient!.photoUrl!,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: LinearProgressIndicator(
                          value: downloadProgress.progress,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Constants.primaryColor400
                          ),
                          backgroundColor:Constants.primaryColor600,
                        ),
                      ),
                    errorWidget: (context, url,  error) => const Icon(Icons.error),
                  ),
            ),
          )
          // first name and last name

          // decription

        ],
      ),
    );
  }
}
