import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/Doctor.dart';
import '../../constants.dart';
import '../../utils/helpers.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({Key key, @required this.doctor}) : super(key: key);
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: SvgPicture.asset('assets/Logo.svg',
                semanticsLabel: 'BOLDO Logo'),
          ),
        ),
        body: Background(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 24,
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    size: 25,
                    color: Constants.extraColor400,
                  ),
                  label: Text(
                    'Perfil',
                    style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Card(
                        elevation: 4.0,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 128,
                          width: 128,
                          child: doctor.photoUrl == null
                              ? SvgPicture.asset(
                                  doctor.gender == "female"
                                      ? 'assets/images/femaleDoctor.svg'
                                      : 'assets/images/maleDoctor.svg',
                                  fit: BoxFit.cover)
                              : CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: doctor.photoUrl,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Padding(
                                    padding: const EdgeInsets.all(26.0),
                                    child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Constants.primaryColor400),
                                      backgroundColor:
                                          Constants.primaryColor600,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Text(
                        "${getDoctorPrefix(doctor.gender)}${doctor.givenName} ${doctor.familyName}",
                        style: boldoHeadingTextStyle,
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      if (doctor.specializations != null)
                        for (var specialization in doctor.specializations)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              "${specialization.description}",
                              style: boldoHeadingTextStyle.copyWith(
                                  color: Constants.otherColor100),
                            ),
                          ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      if (doctor.biography != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Biografía",
                              style: boldoHeadingTextStyle,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(doctor.biography,
                                style: boldoSubTextStyle.copyWith(
                                    height: 1.5, fontSize: 16)),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 12,
                      ),
                      if (doctor.languages != null &&
                          doctor.languages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Idiomas",
                              style: boldoHeadingTextStyle,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            for (var language in doctor.languages)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  "- ${language.description}",
                                  style:
                                      boldoSubTextStyle.copyWith(fontSize: 16),
                                ),
                              )
                          ],
                        ),
                      const SizedBox(
                        height: 24,
                      ),
                      if (doctor.license != null && doctor.license != "")
                        Column(
                          children: [
                            const Text(
                              "Registro Profesional",
                              style: boldoHeadingTextStyle,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              "Nro. ${doctor.license}",
                              style: boldoSubTextStyle.copyWith(fontSize: 16),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/decorations/ProfileScreenTopDecoration.svg',
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/decorations/ProfileBottomDecoration.svg',
            ),
          ),
          child,
        ],
      ),
    );
  }
}
