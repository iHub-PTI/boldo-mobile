import 'package:boldo/blocs/prescription_bloc/prescriptionBloc.dart';
import 'package:boldo/blocs/prescriptions_bloc/prescriptionsBloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';

import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/medical_records/prescriptions_record_screen.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

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
    BlocProvider.of<PrescriptionsBloc>(context).add(GetPastAppointmentWithPrescriptionsList(date: DateTime(dateOffset.year, dateOffset.month, dateOffset.day).toUtc().toIso8601String()));
  }

  void _onRefresh() async {
    dateOffset = DateTime.now().subtract(const Duration(days: 30));
    // monitor network fetch
    BlocProvider.of<PrescriptionsBloc>(context).add(GetPastAppointmentWithPrescriptionsList(date: DateTime(dateOffset.year, dateOffset.month, dateOffset.day).toUtc().toIso8601String()));
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
      body: BlocListener<PrescriptionsBloc, PrescriptionsState>(
          listener: (context, state) {
            if(state is AppointmentWithPrescriptionsLoadedState){
              allAppointments = state.appointments;
            }
          },
        child: Container(
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
              BlocBuilder<PrescriptionsBloc, PrescriptionsState>(builder: (context, state){
                if(state is AppointmentWithPrescriptionsLoadedState){
                  if(allAppointments.isEmpty){
                    return const EmptyStateV2(
                      textBottom: "A medida que uses la aplicación podrás ir"
                          " viendo los medicamentos que te sean recetados",
                    );
                  }else{
                    return Expanded(
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
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PrescriptionRecordScreen(
                                          medicalRecordId:
                                          allAppointments[index].id?? '')),
                            );

                            BlocProvider.of<PrescriptionBloc>(context).add(InitialPrescriptionEvent());
                          },
                          child: Container(
                            width: MediaQuery.of(context)
                                .size
                                .width,
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
                                        const SizedBox(
                                          width: 7,
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
                                                  85,
                                              child: Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                        85)/2,
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
                                                  Container(
                                                    constraints: BoxConstraints(maxWidth: ((MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                        85)/2),),
                                                    width: ((MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                        85)/2),
                                                    child: Column(
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
                                                              mainAxisSize: MainAxisSize.min,
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
                                                                  child:
                                                                    Flexible(
                                                                      child: Text(
                                                                        "${allAppointments[index].prescriptions![0].medicationName}",
                                                                        style: boldoCorpMediumTextStyle.copyWith(
                                                                            color: ConstantsV2.inactiveText,
                                                                            fontSize: 10),
                                                                        overflow:
                                                                        TextOverflow.ellipsis,
                                                                      ),
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
                                                                  child:
                                                                  Flexible(
                                                                    child: Text(
                                                                      "${allAppointments[index].prescriptions![1].medicationName}",
                                                                      style: boldoCorpMediumTextStyle.copyWith(
                                                                          color: ConstantsV2.inactiveText,
                                                                          fontSize: 10),
                                                                      overflow:
                                                                      TextOverflow.ellipsis,
                                                                    ),
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
                                                    ),
                                                  ),
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
                  );
                  }
                }else if(state is Loading){
                  return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                        backgroundColor: Constants.primaryColor600,
                      ));
                }else if(state is Failed){
                  return DataFetchErrorWidget(retryCallback: () => BlocProvider.of<PrescriptionsBloc>(context).add(GetPastAppointmentWithPrescriptionsList(date: DateTime(dateOffset.year, dateOffset.month, dateOffset.day).toUtc().toIso8601String())) ) ;
                }else{
                  return Container();
                }
              }),
            ],
          ),
        ),
      )
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
