import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Appointment.dart';

import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/medical_records/prescriptions_record_screen.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../network/http.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen() : super();

  @override
  _PrescriptionsScreenState createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  bool _dataLoading = true;
  bool _dataLoaded = false;
  late List<Appointment> allAppointments = [];
  DateTime dateOffset = DateTime.now().subtract(const Duration(days: 30));
  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _onRefresh() async {
    setState(() {
      dateOffset = DateTime.now().subtract(const Duration(days: 30));
    });
    // monitor network fetch
    await _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      Response responseAppointments;
      Response responsePrescriptions;
      if (!prefs.getBool(isFamily)!)
        responseAppointments = await dio.get(
            "/profile/patient/appointments?start=${DateTime(dateOffset.year, dateOffset.month, dateOffset.day).toUtc().toIso8601String()}");
      else
        responseAppointments = await dio.get(
            "/profile/caretaker/dependent/${patient.id}/appointments?start=${DateTime(dateOffset.year, dateOffset.month, dateOffset.day).toUtc().toIso8601String()}");
      if (!prefs.getBool(isFamily)!)
        responsePrescriptions = await dio.get("/profile/patient/prescriptions");
      else
        responsePrescriptions = await dio
            .get("/profile/caretaker/dependent/${patient.id}/prescriptions");
      List<Prescription> allPrescriptions = List<Prescription>.from(
          responsePrescriptions.data["prescriptions"]
              .map((i) => Prescription.fromJson(i)));

      allAppointments = List<Appointment>.from(responseAppointments
          .data["appointments"]
          .map((i) => Appointment.fromJson(i)));

      for (Appointment appointment in allAppointments) {
        for (Prescription prescription in allPrescriptions) {
          if (prescription.encounter != null &&
              prescription.encounter!.appointmentId == appointment.id) {
            if (appointment.prescriptions != null) {
              appointment.prescriptions = [
                ...appointment.prescriptions!,
                prescription
              ];
            } else {
              appointment.prescriptions = [prescription];
            }
          }
        }
      }

      allAppointments = allAppointments
          .where((element) => element.prescriptions != null)
          .toList();

      setState(() {
        _dataLoading = false;
        _dataLoaded = true;
      });
    } on DioError catch (exception, stackTrace) {
      print(exception);
      setState(() {
        _dataLoading = false;
        _dataLoaded = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);
      setState(() {
        _dataLoading = false;
        _dataLoaded = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: _dataLoading == true
          ? const Center(
              child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
              backgroundColor: Constants.primaryColor600,
            ))
          : Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        size: 25,
                        color: Constants.extraColor400,
                      ),
                      label: Text(
                        'Mis Recetas',
                        style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                      ),
                    ),
                  ),
                  if (!_dataLoading && !_dataLoaded)
                    const Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Center(
                        child: Text(
                          "Algo salió mal. Por favor, inténtalo de nuevo más tarde.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Constants.otherColor100,
                          ),
                        ),
                      ),
                    ),
                  if (!_dataLoading && _dataLoaded)
                    allAppointments.isEmpty
                        ? const EmptyStateV2(
                            picture: "feed_empty.svg",
                            textTop: "Nada para mostrar",
                          )
                        : SizedBox(
                            child: ListView.separated(
                              itemCount: allAppointments.length,
                              shrinkWrap: true,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                color: Colors.transparent,
                              ),
                              itemBuilder: (context, index) {
                                int daysDifference = DateTime.now()
                                    .difference(DateTime.parse(
                                            allAppointments[index].start!)
                                        .toLocal())
                                    .inDays;
                                return GestureDetector(
                                  onTap: () async {
                                    _dataLoading = true;
                                    try {
                                      String url =
                                          "${prefs.getBool(isFamily) == true ? '/profile/caretaker/dependent/${patient.id}/appointments/${allAppointments[index].id}/encounter' : ' /profile/patient/appointments/${allAppointments[index].id}/encounter?includePrescriptions=true&includeSoep=true'}".trim();
                                      MedicalRecord medicalRecord;
                                      Response response =
                                          await dioHealthCore.get(url);
                                      if (response.statusCode == 200) {
                                        print(response.data);
                                        medicalRecord = MedicalRecord.fromJson(
                                            response.data);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PrescriptionRecordScreen(
                                                      medicalRecord:
                                                          medicalRecord)),
                                        );
                                        _dataLoading = false;
                                      } else {
                                        _dataLoaded = false;
                                        _dataLoading = false;
                                      }
                                    } catch (e) {
                                      _dataLoaded = false;
                                      _dataLoading = false;
                                      print("ERROR $e");
                                    }
                                  },
                                  child: Container(
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Text(
                                                //   "Receta",
                                                //   style: boldoCorpSmallTextStyle
                                                //       .copyWith(
                                                //           color: ConstantsV2
                                                //               .darkBlue),
                                                // ),
                                                const Spacer(),
                                                Text(
                                                  daysDifference == 0
                                                      ? "hoy"
                                                      : '${DateFormat('dd/MM/yy').format(DateTime.parse(allAppointments[index].start!).toLocal())}',
                                                  style: boldoCorpSmallTextStyle
                                                      .copyWith(
                                                          color: ConstantsV2
                                                              .inactiveText),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                ClipOval(
                                                  child: SizedBox(
                                                    width: 54,
                                                    height: 54,
                                                    child: allAppointments[
                                                                    index]
                                                                .doctor
                                                                ?.photoUrl ==
                                                            null
                                                        ? SvgPicture.asset(
                                                            allAppointments[index]
                                                                        .doctor!
                                                                        .gender ==
                                                                    "female"
                                                                ? 'assets/images/femaleDoctor.svg'
                                                                : 'assets/images/maleDoctor.svg',
                                                            fit: BoxFit.cover)
                                                        : CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl: allAppointments[
                                                                        index]
                                                                    .doctor!
                                                                    .photoUrl ??
                                                                '',
                                                            progressIndicatorBuilder:
                                                                (context, url,
                                                                        downloadProgress) =>
                                                                    Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      26.0),
                                                              child:
                                                                  LinearProgressIndicator(
                                                                value:
                                                                    downloadProgress
                                                                        .progress,
                                                                valueColor: const AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    Constants
                                                                        .primaryColor400),
                                                                backgroundColor:
                                                                    Constants
                                                                        .primaryColor600,
                                                              ),
                                                            ),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .error),
                                                          ),
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              90,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: 150,
                                                            child: Flex(direction: Axis.horizontal,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    "${getDoctorPrefix(allAppointments[index].doctor!.gender!)}${allAppointments[index].doctor!.familyName}",
                                                                    style: boldoSubTextMediumStyle,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              if (allAppointments[
                                                                          index]
                                                                      .prescriptions![
                                                                          0]
                                                                      .encounter !=
                                                                  null)
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          4.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SvgPicture
                                                                          .asset(
                                                                        'assets/icon/pill.svg',
                                                                        color: const Color(
                                                                            0xff707882),
                                                                        // height: 8,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      Container(
                                                                        width:
                                                                            130,
                                                                        child:
                                                                            Text(
                                                                          "${allAppointments[index].prescriptions![0].medicationName}",
                                                                          style: boldoCorpMediumTextStyle.copyWith(
                                                                              color: ConstantsV2.inactiveText,
                                                                              fontSize: 10),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              if (allAppointments[
                                                                          index]
                                                                      .prescriptions!
                                                                      .length >
                                                                  1)
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          4.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SvgPicture
                                                                          .asset(
                                                                        'assets/icon/pill.svg',
                                                                        color: const Color(
                                                                            0xff707882),
                                                                        // height: 8,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      Container(
                                                                        width:
                                                                            130,
                                                                        child:
                                                                            Text(
                                                                          "${allAppointments[index].prescriptions![1].medicationName}",
                                                                          style: boldoCorpMediumTextStyle.copyWith(
                                                                              color: ConstantsV2.inactiveText,
                                                                              fontSize: 10),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                             
                                                              if (allAppointments[
                                                                          index]
                                                                      .prescriptions!
                                                                      .length >
                                                                  2)
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      'assets/icon/add.svg',
                                                                      color: const Color(
                                                                          0xff707882),
                                                                      // height: 8,
                                                                      width: 15,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      "${allAppointments[index].prescriptions!.length - 2}",
                                                                      style: boldoCorpMediumTextStyle.copyWith(
                                                                          color: ConstantsV2
                                                                              .inactiveText,
                                                                          fontSize:
                                                                              10),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    Text(
                                                                      "ver todo",
                                                                      style: boldoCorpMediumTextStyle.copyWith(
                                                                          color: ConstantsV2
                                                                              .orange,
                                                                          fontSize:
                                                                              10),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    if (allAppointments[index]
                                                                .doctor!
                                                                .specializations !=
                                                            null &&
                                                        allAppointments[index]
                                                            .doctor!
                                                            .specializations!
                                                            .isNotEmpty)
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            90,
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            children: [
                                                              for (int i = 0;
                                                                  i <
                                                                      allAppointments[
                                                                              index]
                                                                          .doctor!
                                                                          .specializations!
                                                                          .length;
                                                                  i++)
                                                                Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: i ==
                                                                              0
                                                                          ? 0
                                                                          : 3.0,
                                                                      bottom:
                                                                          5),
                                                                  child: Text(
                                                                    "${toLowerCase(allAppointments[index].doctor!.specializations![i].description ?? '')}${allAppointments[index].doctor!.specializations!.length > 1 && i == 0 ? "," : ""}",
                                                                    style: boldoCorpMediumTextStyle
                                                                        .copyWith(
                                                                            color:
                                                                                ConstantsV2.inactiveText),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),

                                                // SizedBox(
                                                //   width: 124,
                                                //   height: 42,
                                                //   child: Column(
                                                //     children: [

                                                //       // for (int i = 0;
                                                //       //     i <
                                                //       //         allAppointments[
                                                //       //                 index]
                                                //       //             .prescriptions!
                                                //       //             .length;
                                                //       //     i++)
                                                //       //   Row(
                                                //       //     children: [
                                                //       //       SvgPicture.asset(
                                                //       //         'assets/icon/pill.svg',
                                                //       //         color: Color(
                                                //       //             0xff707882),
                                                //       //         // height: 8,
                                                //       //         width: 15,
                                                //       //       ),
                                                //       //       const SizedBox(width: 10),
                                                //       //       Flexible(
                                                //       //         child: Text(
                                                //       //           "${allAppointments[index].prescriptions![i].medicationName}",
                                                //       //           style: boldoCorpMediumTextStyle.copyWith(
                                                //       //               color: ConstantsV2
                                                //       //                   .inactiveText,
                                                //       //               fontSize:
                                                //       //                   10),
                                                //       //           overflow:
                                                //       //               TextOverflow
                                                //       //                   .ellipsis,
                                                //       //         ),
                                                //       //       ),
                                                //       //     ],
                                                //       //   ),
                                                //     ],
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                ],
              ),
            ),
    );
  }
}

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
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
