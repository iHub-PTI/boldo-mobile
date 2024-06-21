import 'package:boldo/constants.dart';
import 'package:boldo/features/doctor_search/presentation/presentation.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/screens/doctor_profile/doctor_profile_screen.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoctorBoxWidget extends StatelessWidget {
  const DoctorBoxWidget({
    required this.doctor,
    required this.onSuccessFavoriteAction,
    super.key,
  });

  final Doctor doctor;
  final VoidCallback? onSuccessFavoriteAction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfileScreen(
              doctor: doctor,
              showAvailability: true,
            ),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Stack(
          children: <Widget>[
            // the first item in stack is the doctor profile photo
            if (doctor.photoUrl != null)
              Positioned.fill(
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: doctor.photoUrl!,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Padding(
                    padding: const EdgeInsets.all(26),
                    child: Center(
                      child: loadingStatus(
                        value: downloadProgress.progress,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            else
              Positioned.fill(
                child: doctor.gender == 'female'
                    ? SvgPicture.asset(
                        'assets/images/femaleDoctor.svg',
                        fit: BoxFit.cover,
                      )
                    : doctor.gender == 'male'
                        ? SvgPicture.asset(
                            'assets/images/maleDoctor.svg',
                            fit: BoxFit.cover,
                          )
                        : SvgPicture.asset(
                            'assets/images/persona.svg',
                            fit: BoxFit.cover,
                          ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: RadialGradient(
                  radius: 3,
                  center: Alignment.bottomLeft,
                  stops: const [0.08, 0.72],
                  colors: [Colors.black, Colors.black.withOpacity(0)],
                ),
              ),
            ),
            // the second item in stack is the column of details
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    DoctorFavoriteIcon(
                      doctor: doctor,
                      onSuccessCallback: onSuccessFavoriteAction,
                    ),
                  ],
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // name of the doctor
                        Row(
                          children: [
                            // this for jump if there is overflow
                            Flexible(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      right: 16,
                                      bottom: 2,
                                    ),
                                    child: Text(
                                      '${doctor.gender == 'female' ? 'Dra.' : 'Dr.'} ${doctor.givenName!.split(" ")[0]} ${doctor.familyName!.split(" ")[0]}',
                                      style: boldoCardHeadingTextStyle.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // specializations
                        if (doctor.specializations != null)
                          doctor.specializations!.isNotEmpty
                              ? Container(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          for (int i = 0;
                                              i <
                                                  doctor
                                                      .specializations!.length;
                                              i++)
                                            Text(
                                              "${doctor.specializations![i].description}${doctor.specializations!.length - 1 != i ? ", " : ""}",
                                              style: boldoBodyLRegularTextStyle
                                                  .copyWith(
                                                color: ConstantsV2
                                                    .buttonPrimaryColor100,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                        else
                          Container(),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: AvailabilityHourWidget(
                            organizations: doctor.organizations,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
