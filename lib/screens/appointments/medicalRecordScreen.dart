import 'package:boldo/blocs/medical_record_bloc/medicalRecordBloc.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/Soep.dart';
import 'package:boldo/screens/medical_records/prescriptions_record_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final encounterId;

  const MedicalRecordsScreen({@required this.encounterId});

  @override
  _MedicalRecordsScreenState createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  bool _dataLoaded = false;
  bool _dataLoading = true;
  List<MedicalRecord> allMedicalData = [];
  MedicalRecord? medicalRecord;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<MedicalRecordBloc>(context).add(GetMedicalRecord(appointmentId: widget.encounterId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicalRecordBloc, MedicalRecordState>(
        listener: (context, state){
          if(state is Success) {
            setState(() {
              _dataLoading = false;
              _dataLoaded = true;
            });
          }else if(state is Failed){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response!),
                backgroundColor: Colors.redAccent,
              ),
            );
            _dataLoading = false;
            _dataLoaded = false;
          }else if(state is Loading){
            setState(() {
              _dataLoading = true;
              _dataLoaded = false;
            });
          }else if(state is MedicalRecordLoadedState){
            medicalRecord = state.medicalRecord;
          }
        },
        child: BlocBuilder<MedicalRecordBloc, MedicalRecordState>(
            builder: (context, state) {
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
                    ? const Text(
                  'Anotacion medica',
                )
                    : Padding(
                  padding: const EdgeInsets.all(15.0),
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
                              'Anotacion medica',
                              style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                            ),
                          ],
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("Motivo principal",
                                        style: boldoSubTextStyle),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      medicalRecord?.mainReason??'',
                                      style: boldoHeadingTextStyle.copyWith(
                                          fontSize: 20,
                                          color: Constants.primaryColor500),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SoepAccordion(
                                      title: Constants.subjective,
                                      medicalRecord: medicalRecord!),
                                  const Divider(
                                    color: Constants.dividerAccordion,
                                    thickness: 1,
                                  ),
                                  SoepAccordion(
                                      title: Constants.objective,
                                      medicalRecord: medicalRecord!),
                                  const Divider(
                                      color: Constants.dividerAccordion,
                                      thickness: 1),
                                  SoepAccordion(
                                      title: Constants.evaluation,
                                      medicalRecord: medicalRecord!),
                                  const Divider(
                                      color: Constants.dividerAccordion,
                                      thickness: 1),
                                  SoepAccordion(
                                      title: Constants.plan,
                                      medicalRecord: medicalRecord!),
                                  const Divider(
                                      color: Constants.dividerAccordion,
                                      thickness: 1),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
        )
    );
  }
}


class SoepAccordion extends StatefulWidget {
  final String title;
  final MedicalRecord medicalRecord;

  SoepAccordion({required this.title, required this.medicalRecord});
  @override
  _SoepAccordionState createState() => _SoepAccordionState();
}

class _SoepAccordionState extends State<SoepAccordion> {
  bool _showContent = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Constants.accordionbg,
      margin: const EdgeInsets.only(top: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        ListTile(
          title: Text(
            widget.title,
            style: boldoHeadingTextStyle.copyWith(
                fontSize: 18, color: Constants.primaryColor500),
          ),
          trailing: IconButton(
            icon: Icon(
              _showContent ? Icons.expand_less : Icons.expand_more,
              color: Constants.primaryColor500,
            ),
            onPressed: () {
              setState(() {
                _showContent = !_showContent;
              });
            },
          ),
        ),
        _showContent
            ? Container(
          height: 250,
          // width:300,
          padding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: SoepScreen(widget.medicalRecord, widget.title),
        )
            : Container()
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
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            soep.objective ?? 'Sin datos',
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
          ),
        );
      case Constants.subjective:
        return Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            soep.subjective ?? 'Sin datos',
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
          ),
        );
      case Constants.evaluation:
        return Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            soep.evaluation ?? 'Sin datos',
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
          ),
        );
      case Constants.plan:
        return Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            soep.plan ?? 'Sin datos',
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
          ),
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Container(
        width: 300,
        child: Card(
          color: Constants.accordionbg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    medicalRecord.prescription!.isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PrescriptionRecordScreen(medicalRecord:  medicalRecord)),
                        );
                      },
                      child: SvgPicture.asset('assets/icon/pill.svg',
                          fit: BoxFit.cover),
                    )
                        : Container(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    //HH:mm  dd/MM/yy
                      DateFormat('dd/MM/yy').format(
                          DateTime.parse(medicalRecord.startTimeDate!)
                              .toLocal()),
                      style: boldoHeadingTextStyle.copyWith(
                          fontSize: 20, fontWeight: FontWeight.w500)),
                ),
                soepDescription(medicalRecord.soep!)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
