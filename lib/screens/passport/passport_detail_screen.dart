import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/VaccinationList.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../widgets/background.dart';

class PassportDetail extends StatefulWidget {
  final UserVaccinate? userVaccinate;
  const PassportDetail({Key? key, this.userVaccinate}) : super(key: key);

  @override
  State<PassportDetail> createState() => _PassportDetailState();
}

// implementation of the PassportDetail state
class _PassportDetailState extends State<PassportDetail> {
  late PageController controller;
  // initial state of the page
  @override
  void initState() {
    controller = PageController();
    super.initState();
  }

  bool _completeVaccineRecord() {
    // variable that we will return, false for default
    bool result = false;
    // today's date for comparison
    DateTime today = DateTime.now();

    if (widget.userVaccinate!.diseaseCode == 'COVID-19') {
      // in this case, with two doses we have a complete scheme
      if (widget.userVaccinate!.vaccineApplicationList!.length >= 2) {
        result = true;
      }
    } else if (widget.userVaccinate!.diseaseCode == 'Influenza') {
      // in this case, we must have annual dose.
      // we get the most recent vaccine date (only year)
      final nearestDate = widget.userVaccinate!.vaccineApplicationList!.reduce(
          (a, b) =>
              a.vaccineApplicationDate.year > b.vaccineApplicationDate.year
                  ? a
                  : b);
      // if the nearest Date match with the current year, the scheme is complete
      if (today.year == nearestDate.vaccineApplicationDate.year) {
        result = true;
      }
    } else if (widget.userVaccinate!.diseaseCode == 'Varicela') {
      // if the list is empty, the result is false obviously
      if (widget.userVaccinate!.vaccineApplicationList!.length > 0) {
        // here we can have two options.
        if (widget.userVaccinate!.vaccineApplicationList![0].vaccineName ==
            'MMRV') {
          // two doses is the correct
          if (widget.userVaccinate!.vaccineApplicationList!.length == 2) {
            result = true;
          }
        } else if (widget
                .userVaccinate!.vaccineApplicationList![0].vaccineName ==
            'MMR') {
          // one dose is the correct
          if (widget.userVaccinate!.vaccineApplicationList!.length == 1) {
            result = true;
          }
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        // the first element of the stack is the background
        const Background(text: "linkFamily"),
        // the second element is the body which adapts to the rotation
        MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    // close the passport
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25, right: 15),
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon:
                                const Icon(Icons.close, color: Colors.black45)),
                      ),
                    ),
                    // health passport
                    const Text(
                      'Pasaporte de Salud',
                      style: boldoTitleBlackTextStyle,
                    ),
                    // space between profile photo and boldo logo
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.007,
                    ),
                    // profile photo
                    Profile(),
                    // space between profile photo and vaccinate state
                    const SizedBox(height: 10),
                    // vaccinate state
                    Container(
                      width: 225,
                      height: 100,
                      child: Card(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            side: BorderSide(
                                width: 3, color: Constants.accordionbg)),
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(8),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      '${widget.userVaccinate!.diseaseCode}'),
                                )),
                            // there is vaccination list
                            widget.userVaccinate!.vaccineApplicationList != null
                                ? _completeVaccineRecord()
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                                'assets/icon/check.svg'),
                                            const SizedBox(width: 5),
                                            const Text(
                                              'Esquema completo',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      40, 187, 143, 1)),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Align(
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icon/check.svg',
                                              color: Colors.yellow,
                                            ),
                                            const SizedBox(width: 5),
                                            const Text('Esquema incompleto'),
                                          ],
                                        ),
                                      )
                                : const Align(
                                    alignment: Alignment.center,
                                    child: Text('No hay lista')),
                            // see more details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    //_showMyDialog();
                                  },
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'ver detalles',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(235, 139, 118, 1)),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    // space between vaccinate state and QR
                    const SizedBox(
                      height: 10,
                    ),
                    // HERE THE QR CONSTRUCTOR
                  ])
            : Stack()
      ],
    ));
  }
}

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // profile photo container
        Container(
            // adaptive dimensions of the container
            height: MediaQuery.of(context).size.height * 0.25,
            width: MediaQuery.of(context).size.width > 600
                ? MediaQuery.of(context).size.width * 0.28
                : MediaQuery.of(context).size.width * 0.415,
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              color: Colors.black,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: patient.photoUrl != null
                    ? CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: patient.photoUrl!,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : SvgPicture.asset('assets/images/malePatient.svg'),
              ),
            )),
        // person name and ci
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // person name
              Text(
                  '${patient.givenName != null ? capitalize(patient.givenName!.split(" ")[0].toLowerCase().toString()) : ''} ${patient.familyName != null ? capitalize(patient.familyName!.split(" ")[0].toLowerCase().toString()) : ''}',
                  style: boldoSubTextMediumStyle.copyWith(fontSize: 16)),
              // space between name and ci
              const SizedBox(
                width: 10,
              ),
              // person ci
              Text(
                'CI: ${patient.identifier != null ? patient.identifier : 'vacío'}',
                style: boldoSubTextMediumStyle.copyWith(fontSize: 16),
              ),
            ]),
      ],
    );
  }
}
