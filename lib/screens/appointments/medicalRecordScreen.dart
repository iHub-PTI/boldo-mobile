import 'package:boldo/blocs/medical_record_bloc/medicalRecordBloc.dart';
import 'package:boldo/blocs/prescription_bloc/prescriptionBloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/PresciptionMedicalRecord.dart';
import 'package:boldo/models/Soep.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/medical_records/prescriptions_record_screen.dart';
import 'package:boldo/screens/my_studies/estudy_screen.dart';
import 'package:boldo/screens/studies_orders/ProfileDescription.dart';
import 'package:boldo/screens/studies_orders/StudyOrderScreen.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final Appointment appointment;

  const MedicalRecordsScreen({required this.appointment});

  @override
  _MedicalRecordsScreenState createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  MedicalRecord? medicalRecord;
  int _daysBetween = 0;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<MedicalRecordBloc>(context)
        .add(GetMedicalRecord(appointmentId: widget.appointment.id ?? "0"));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicalRecordBloc, MedicalRecordState>(
        listener: (context, state) {
          if (state is Failed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response!),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state is MedicalRecordLoadedState) {
            medicalRecord = state.medicalRecord;
            _daysBetween = daysBetween(
                DateTime.parse(widget.appointment.start ??
                    DateTime.now().toIso8601String()),
                DateTime.now());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: SvgPicture.asset('assets/Logo.svg',
                  semanticsLabel: 'BOLDO Logo'),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chevron_left_rounded,
                        size: 25,
                        color: Constants.extraColor400,
                      ),
                      Text(
                        'Detalles de Cita',
                        style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<MedicalRecordBloc, MedicalRecordState>(
                    builder: (context, state) {
                  if (state is Loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Constants.primaryColor400),
                        backgroundColor: Constants.primaryColor600,
                      ),
                    );
                  } else if (state is Success) {
                    return Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${formatDate(
                                        DateTime.parse(widget
                                                .appointment.start ??
                                            DateTime.now().toIso8601String()),
                                        [d, ' de ', MM, ' de ', yyyy],
                                        locale: const SpanishDateLocale(),
                                      )} (hace $_daysBetween ${_daysBetween == 1 ? "día" : "días"})',
                                      style: boldoCorpMediumTextStyle.copyWith(
                                          color: ConstantsV2.darkBlue),
                                    ),
                                    medicalRecord?.mainReason != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 15.0),
                                          child: Text(
                                              medicalRecord!.mainReason!,
                                              style: boldoCorpMediumBlackTextStyle
                                                  .copyWith(
                                                      color: ConstantsV2.darkBlue)),
                                        )
                                      : Container(),
                                  ],
                                ),
                              ),
                              // buttons for navigate
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  medicalRecord != null 
                                    ? medicalRecord!.serviceRequests != null
                                      ? // show past appointments
                                        GestureDetector(
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                                            child: SvgPicture.asset('assets/icon/icon-show-appointments-orange.svg'),
                                          )
                                        )
                                      : Container()
                                    : Container()
                                  
                                ],
                              ),
                              Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // doctor and patient profile
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // doctor
                                        ProfileDescription(
                                            doctor: widget.appointment.doctor,
                                            type: "doctor"),
                                        const SizedBox(height: 20),
                                        // patient
                                        ProfileDescription(
                                            patient: patient, type: "patient"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  elevation: 0,
                                  color: ConstantsV2.lightest,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icon/clipboard.svg',
                                              height: 12,
                                              width: 12,
                                            ),
                                            const Text('Notas')
                                          ],
                                        ),
                                      ),
                                      // SoepAccordion(
                                      //     title: Constants.subjective,
                                      //     medicalRecord: medicalRecord!),
                                      // const Divider(
                                      //   color: Constants.dividerAccordion,
                                      //   thickness: 1,
                                      // ),
                                      // SoepAccordion(
                                      //     title: Constants.objective,
                                      //     medicalRecord: medicalRecord!),
                                      // const Divider(
                                      //     color: Constants.dividerAccordion,
                                      //     thickness: 1),
                                      // SoepAccordion(
                                      //     title: Constants.evaluation,
                                      //     medicalRecord: medicalRecord!),
                                      // const Divider(
                                      //     color: Constants.dividerAccordion,
                                      //     thickness: 1),
                                      SoepAccordion(
                                          title: Constants.plan,
                                          medicalRecord: medicalRecord!),
                                      // const Divider(
                                      //     color: Constants.dividerAccordion,
                                      //     thickness: 1),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  elevation: 0,
                                  color: ConstantsV2.lightest,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icon/pill.svg',
                                              height: 12,
                                              width: 12,
                                            ),
                                            const Text('Receta')
                                          ],
                                        ),
                                      ),
                                      medicalRecord?.prescription != null
                                        ? medicalRecord!.prescription!.length > 0
                                          ? ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemCount: medicalRecord!.prescription!.length > 3 ? 3 : medicalRecord!.prescription!.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return ShowPrescription(
                                                  context, medicalRecord!.prescription![index]
                                                );
                                              }
                                          )
                                          : Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'No posee medicamentos recetados',
                                                style: boldoCorpMediumTextStyle.copyWith(
                                                    color: ConstantsV2.darkBlue),
                                              ),
                                            )
                                        : Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'No posee medicamentos recetados',
                                                style: boldoCorpMediumTextStyle.copyWith(
                                                    color: ConstantsV2.darkBlue),
                                              ),
                                            ),
                                      medicalRecord?.prescription != null
                                        ? medicalRecord!.prescription!.length > 0
                                          ? Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children:[
                                              Container(
                                                child: GestureDetector(
                                                  onTap: medicalRecord!.prescription!.length > 0
                                                    ? () async {
                                                        await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => PrescriptionRecordScreen(
                                                                  medicalRecordId: medicalRecord?.appointmentId ?? '')),
                                                        );
                                                        BlocProvider.of<PrescriptionBloc>(context)
                                                            .add(InitialPrescriptionEvent());
                                                      }
                                                    : null,
                                                  child: Card(
                                                    margin: EdgeInsets.zero,
                                                    clipBehavior: Clip.antiAlias,
                                                    elevation: 0,
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(5)),
                                                    ),
                                                    color: ConstantsV2.orange.withOpacity(0.10),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 15, vertical: 7),
                                                      child: const Text("ver receta"),
                                                    )
                                                  ),
                                                ),
                                              )
                                            ]
                                          )
                                          : Container()
                                        : Container(),
                                      
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  elevation: 0,
                                  color: ConstantsV2.lightest,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icon/test-tube 1.svg',
                                              height: 12,
                                              width: 12,
                                              color: const Color.fromRGBO(54, 79, 107, 1),
                                            ),
                                            const Text('Órdenes de estudio')
                                          ],
                                        ),
                                      ),
                                      ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: medicalRecord?.serviceRequests!.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return ShowStudy(
                                              context, medicalRecord?.serviceRequests![index] ??  ServiceRequest());
                                        }
                                      ),
                                      medicalRecord?.serviceRequests != null
                                        ? medicalRecord!.serviceRequests!.length > 0
                                          ? Container()
                                          : Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'No posee órdenes de estudios',
                                              style: boldoCorpMediumTextStyle.copyWith(
                                                  color: ConstantsV2.darkBlue),
                                            ),
                                          )
                                        : Container(),
                                      medicalRecord?.serviceRequests != null
                                        ? medicalRecord!.serviceRequests!.length > 0
                                          ? Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                child: GestureDetector(
                                                  onTap: (){
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            StudyOrderScreen(callFromHome: false, encounterId: medicalRecord?.id?? "0")
                                                      ),
                                                    );
                                                  },
                                                  child: Card(
                                                      margin: EdgeInsets.zero,
                                                      clipBehavior: Clip.antiAlias,
                                                      elevation: 0,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(5)),
                                                      ),
                                                      color: ConstantsV2.orange.withOpacity(0.10),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 15, vertical: 7),
                                                        child: const Text("ver órdenes"),
                                                      )),
                                                ),
                                              ),
                                            ],
                                          )
                                          : Container()
                                        : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (state is Failed) {
                    return DataFetchErrorWidget(
                        retryCallback: () =>
                            BlocProvider.of<MedicalRecordBloc>(context).add(
                                GetMedicalRecord(
                                    appointmentId:
                                        widget.appointment.id ?? "0")));
                  } else {
                    return Container();
                  }
                }),
              ],
            ),
          ),
        ));
  }
}


Widget ShowStudy(BuildContext context, ServiceRequest study) {
  return Column(
    children: [
      Row(
        children: [
          // the orange circle
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                  color: ConstantsV2.orange, shape: BoxShape.circle),
            ),
          ),
          // type of the study
          Text(
            study.category != null
                ? study.category == 'Laboratory'
                    ? 'Laboratorio'
                    : study.category == 'Diagnostic Imaging'
                        ? 'Imágenes'
                        : 'Otros'
                : 'Desconocido',
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
          ),
          const SizedBox(width: 10,),
          study.urgent ?? false
              ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                  color: ConstantsV2.orange,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 6.0, top: 2.0, bottom: 2.0, right: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icon/warning-white.svg',
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "urgente",
                          style: boldoCorpSmallTextStyle.copyWith(
                              color: ConstantsV2.lightGrey),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              study.description != null ? '${study.description}' : '',
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  color: ConstantsV2.inactiveText),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget ShowPrescription (BuildContext context, PrescriptionMedicalRecord prescription) {
  return Column(
    children: [
      Row(
        children: [
          // the orange circle
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                  color: ConstantsV2.orange, shape: BoxShape.circle),
            ),
          ),
          // name of the medicine
          Text(
            prescription.medicationName != null
              ? prescription.medicationName!
              : 'Nombre desconocido',
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              prescription.instructions != null ? prescription.instructions! : 'Este medicamento no posee instrucciones',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                color: ConstantsV2.inactiveText
              ),
            ),
          )
        ],
      ),
      const SizedBox(height: 10,)
    ],
  );
}

class SoepAccordion extends StatefulWidget {
  final String title;
  final MedicalRecord medicalRecord;

  SoepAccordion({required this.title, required this.medicalRecord});
  @override
  _SoepAccordionState createState() => _SoepAccordionState();
}

class _SoepAccordionState extends State<SoepAccordion> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget.title,
          style: boldoCorpMediumBlackTextStyle.copyWith(
              color: ConstantsV2.activeText),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          child: SoepScreen(widget.medicalRecord, widget.title),
        )
      ]),
    );
  }
}

class SoepScreen extends StatelessWidget {
  final String title;
  final MedicalRecord medicalRecord;
  SoepScreen(this.medicalRecord, this.title);

  Widget soepDescription(Soep soep) {
    switch (title) {
      case Constants.objective:
        return Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Text(
            soep.objective ?? 'Sin datos',
            style: boldoCorpMediumWithLineSeparationLargeTextStyle.copyWith(
                color: ConstantsV2.activeText),
          ),
        );
      case Constants.subjective:
        return Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Text(
            soep.subjective ?? 'Sin datos',
            style: boldoCorpMediumWithLineSeparationLargeTextStyle.copyWith(
                color: ConstantsV2.activeText),
          ),
        );
      case Constants.evaluation:
        return Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Text(
            soep.evaluation ?? 'Sin datos',
            style: boldoCorpMediumWithLineSeparationLargeTextStyle.copyWith(
                color: ConstantsV2.activeText),
          ),
        );
      case Constants.plan:
        return Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Text(
            soep.plan ?? 'Sin datos',
            style: boldoCorpMediumWithLineSeparationLargeTextStyle.copyWith(
                color: ConstantsV2.activeText),
          ),
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Container(
        width: 300,
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (medicalRecord.soep != null)
                  soepDescription(medicalRecord.soep!)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrescriptionPreview extends StatelessWidget {
  final List<PrescriptionMedicalRecord>? prescriptionList;
  final String? appointmentId;
  PrescriptionPreview(
      {required this.prescriptionList, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Container(
        child: GestureDetector(
          onTap: prescriptionList != null && prescriptionList!.length > 0
              ? () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrescriptionRecordScreen(
                            medicalRecordId: appointmentId ?? '')),
                  );
                  BlocProvider.of<PrescriptionBloc>(context)
                      .add(InitialPrescriptionEvent());
                }
              : null,
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: prescriptionList != null && prescriptionList!.length > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (prescriptionList!.length > 1)
                          prescriptionIndividual(prescriptionList![0]),
                        if (prescriptionList!.length > 2)
                          prescriptionIndividual(prescriptionList![1]),
                        if (prescriptionList!.length > 2) const Text('ver más'),
                      ],
                    )
                  : Text(
                      'No posee medicamentos recetados',
                      style: boldoCorpMediumTextStyle.copyWith(
                          color: ConstantsV2.darkBlue),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget prescriptionIndividual(PrescriptionMedicalRecord prescription) {
    return Row(
      children: [
        const Icon(
          Icons.circle,
          color: ConstantsV2.orange,
        ),
        Column(
          children: [
            Text("${prescription.medicationName}"),
            Text("${prescription.instructions}"),
          ],
        )
      ],
    );
  }
}
