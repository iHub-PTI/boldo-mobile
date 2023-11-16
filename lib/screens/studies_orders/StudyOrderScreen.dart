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
import 'package:boldo/screens/studies_orders/components/studyOrderCard.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants.dart';
import 'components/selectableStudiesOrders.dart';

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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                              MedicalRecordsScreen(appointment: appointment!),
                        settings: RouteSettings(name: (MedicalRecordsScreen).toString()),
                      ),
                    );
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
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackButtonLabel(
                    labelText: 'Órdenes de estudio',
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: BlocBuilder<StudyOrderBloc, StudyOrderState>(
                      builder: (context, state) {
                        if (state is StudyOrderLoaded || state is AppointmentLoaded
                            || state is LoadingAppointment) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '${formatDate(
                                    DateTime.parse(studiesOrders?.authoredDate ??
                                        DateTime.now().toString()),
                                    [d, ' de ', MM, ' de ', yyyy],
                                    locale: const SpanishDateLocale(),
                                  )} (${passedDays(_daysBetween, showDateFormat: false)})',
                                  style: boldoCorpMediumTextStyle.copyWith(
                                      color: ConstantsV2.darkBlue),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Expanded(
                                child: studiesOrders?.serviceRequests?.isEmpty ?? true
                                    ? showEmptyList()
                                    : showDiagnosticList(),
                              ),
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
                  ),
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
    return Container(
      child: SelectableServiceRequest(
        servicesRequests: studiesOrders?.serviceRequests?? [],
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
        if(studyOrder.description != null)
        Flexible(
          child: Text(
            "${studyOrder.description}",
          ),
        ),
      ],
    );
  }
}
