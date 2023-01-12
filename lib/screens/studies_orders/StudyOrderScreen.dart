import 'package:boldo/blocs/medical_record_bloc/medicalRecordBloc.dart';
import 'package:boldo/blocs/study_order_bloc/studyOrder_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/appointments/medicalRecordScreen.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/studies_orders/ProfileDescription.dart';
import 'package:boldo/screens/studies_orders/attach_study_by_order.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants.dart';

class StudyOrderScreen extends StatefulWidget {
  final String? encounterId;
  final bool callFromHome;
  StudyOrderScreen(
      {Key? key, required this.callFromHome, required this.encounterId})
      : super(key: key);

  @override
  State<StudyOrderScreen> createState() => _StudyOrderScreenState();
}

class _StudyOrderScreenState extends State<StudyOrderScreen> {
  bool _loading = true;
  bool _error = false;
  int _daysBetween = 0;
  MedicalRecord? encounter;
  StudyOrder? studiesOrders;
  Appointment? appointment;
  @override
  void initState() {
    BlocProvider.of<StudyOrderBloc>(context)
        .add(GetNewsId(encounter: widget.encounterId ?? "0"));

    super.initState();
    _daysBetween = daysBetween(
        DateTime.parse(
            encounter?.startTimeDate ?? DateTime.now().toIso8601String()),
        DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [],
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: MultiBlocListener(
            listeners: [
              BlocListener<StudyOrderBloc, StudyOrderState>(
                listener: (context, state) async {
                  if (state is StudyOrderLoaded) {
                    studiesOrders = state.studyOrder;
                    _daysBetween = daysBetween(
                      DateTime.parse(
                          studiesOrders?.authoredDate ?? DateTime.now().toIso8601String()),
                      DateTime.now());
                  }

                  if (state is FailedLoadedOrders) {
                    emitSnackBar(
                        context: context,
                        text: "Falló la obtención de estudios",
                        status: ActionStatus.Fail
                    );
                  }

                  if (state is AppointmentLoaded) {
                    appointment = state.appointment;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MedicalRecordsScreen(appointment: appointment!, fromOrderStudy: true,)),
                    );
                    BlocProvider.of<MedicalRecordBloc>(context).add(InitialEvent());
                  }

                  if (state is FailedLoadAppointment) {
                    emitSnackBar(
                        context: context,
                        text: state.response,
                        status: ActionStatus.Fail
                    );
                  }
                },
              ),
            ],
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      'Órdenes de estudio',
                      style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<StudyOrderBloc, StudyOrderState>(
                      builder: (context, state) {
                    if (state is StudyOrderLoaded || state is AppointmentLoaded
                    || state is LoadingAppointment) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatDate(
                              DateTime.parse(studiesOrders?.authoredDate ??
                                  DateTime.now().toString()),
                              [d, ' de ', MM, ' de ', yyyy],
                              locale: const SpanishDateLocale(),
                            )} (${passedDays(_daysBetween, showDateFormat: false)})',
                            style: boldoCorpMediumTextStyle.copyWith(
                                color: ConstantsV2.darkBlue),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          // here show the profile views
                          Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // doctor and patient profile
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // doctor
                                    ProfileDescription(
                                        doctor: studiesOrders?.doctor,
                                        type: "doctor"),
                                    const SizedBox(height: 20),
                                    // patient
                                    ProfileDescription(
                                        patient: patient, type: "patient"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // here button to origin consult
                                    widget.callFromHome
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: 30, right: 30, bottom: 30),
                                            child: GestureDetector(
                                                onTap: () async {
                                                  BlocProvider.of<
                                                              StudyOrderBloc>(
                                                          context)
                                                      .add(GetAppointment(
                                                          encounter: widget
                                                              .encounterId!));
                                                },
                                                child: BlocBuilder<StudyOrderBloc, StudyOrderState>(
                                                  builder: (context, state) {
                                                    if (state is LoadingAppointment) {
                                                      return Container(
                                                          child: const Center(
                                                              child: CircularProgressIndicator(
                                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                                    Constants.primaryColor400),
                                                                backgroundColor: Constants.primaryColor600,
                                                              )));
                                                    } else {
                                                      return Row(
                                                        children: [
                                                          const Text(
                                                            'ver consulta de origen',
                                                            style: TextStyle(
                                                                decoration:
                                                                TextDecoration
                                                                    .underline,
                                                                fontFamily:
                                                                'Montserrat',
                                                                fontSize: 16),
                                                          ),
                                                          const SizedBox(
                                                            width: 15,
                                                          ),
                                                          SvgPicture.asset(
                                                            'assets/icon/chevron-right.svg',
                                                            height: 12,
                                                          )
                                                        ],
                                                      );
                                                    }
                                                  }
                                                ),
                                            )
                                          )
                                        : Container()
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          studiesOrders?.serviceRequests?.isEmpty ?? true
                              ? showEmptyList()
                              : showDiagnosticList()
                        ],
                      );
                    } else if (state is LoadingOrders) {
                      return Container(
                          child: const Center(
                              child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Constants.primaryColor400),
                        backgroundColor: Constants.primaryColor600,
                      )));
                    } else if (state is FailedLoadedOrders) {
                      return Container(
                          child: DataFetchErrorWidget(
                              retryCallback: () =>
                                  BlocProvider.of<StudyOrderBloc>(context)
                                      .add(GetNews())));
                    } else {
                      return Container();
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showEmptyList() {
    return Center(
      child: Column(children: [
        Text(
          'no tienes órdenes de estudios para visualizar',
          textAlign: TextAlign.center,
          style: boldoSubTextStyle.copyWith(color: ConstantsV2.orange),
        ),
      ]),
    );
  }

  Widget showDiagnosticList() {
    return ListView.builder(
      itemCount: studiesOrders?.serviceRequests?.length ?? 0,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: showStudy,
      physics: const ClampingScrollPhysics(),
    );
  }

  Widget showStudy(BuildContext context, int index) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AttachStudyByOrderScreen(
                        studyOrder: studiesOrders!.serviceRequests![index],
                      )));
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRect(
                        child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: SvgPicture.asset(
                            studiesOrders?.serviceRequests![index].category ==
                                    "Laboratory"
                                ? 'assets/icon/lab-dark.svg'
                                : studiesOrders?.serviceRequests![index]
                                            .category ==
                                        "Diagnostic Imaging"
                                    ? 'assets/icon/image-dark.svg'
                                    : studiesOrders?.serviceRequests![index]
                                                .category ==
                                            "Other"
                                        ? 'assets/icon/other.svg'
                                        : 'assets/images/LogoIcon.svg',
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${studiesOrders?.serviceRequests![index].category == "Laboratory" ? 'Laboratorio' : studiesOrders?.serviceRequests![index].category == "Diagnostic Imaging" ? 'Imágenes' : studiesOrders?.serviceRequests![index].category == "Other" ? 'Otros' : 'Desconocido'}",
                          style: boldoCorpSmallTextStyle.copyWith(
                              color: ConstantsV2.darkBlue),
                        ),
                      ],
                    )),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        studiesOrders?.serviceRequests?[index].urgent ?? false
                            ? Card(
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      top: 2.0,
                                      bottom: 2.0,
                                      right: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "urgente",
                                        style: boldoCorpSmallTextStyle.copyWith(
                                            color: ConstantsV2.orange),
                                      ),
                                      const SizedBox(width: 6),
                                      SvgPicture.asset(
                                        'assets/icon/warning.svg',
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                padding: const EdgeInsets.only(left: 24),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 4,
                      ),
                      listStudiesDisplay(
                          studiesOrders!.serviceRequests![index]),
                      Text(
                        "${studiesOrders?.serviceRequests![index].notes ?? ''}",
                        style: boldoCorpSmallTextStyle.copyWith(
                            color: ConstantsV2.inactiveText),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Impresión diagnóstica: ${studiesOrders?.serviceRequests![index].diagnosis}",
                        style: boldoCorpSmallTextStyle.copyWith(
                            color: ConstantsV2.darkBlue),
                      ),
                      Container(
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icon/attach-file.svg',
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              "${(studiesOrders?.serviceRequests?[index].diagnosticReportCount?? 0)} ${(studiesOrders?.serviceRequests?[index].diagnosticReportCount?? 0) == 1? "archivo adjunto" : "archivos adjuntos"}",
                              style: boldoCorpSmallTextStyle.copyWith(
                                  color: ConstantsV2.darkBlue),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listStudiesDisplay(ServiceRequest studyOrder) {
    return Row(
      children: [
        // if ((studyOrder.studiesCodes?.length ?? 0) > 0)
        //   Text("${studyOrder.studiesCodes![0].display}"),
        // if ((studyOrder.studiesCodes?.length ?? 0) > 1)
        //   Text(", ${studyOrder.studiesCodes![1].display}"),
        // if ((studyOrder.studiesCodes?.length ?? 0) > 2)
        //   Text("... + ${(studyOrder.studiesCodes?.length ?? 0) - 2}"),
        const Text(
          'Estudios',
        ),
      ],
    );
  }
}
