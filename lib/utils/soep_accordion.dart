import 'package:boldo/models/Soep.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/screens/medical_records/prescriptions_record_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class SoepAccordion extends StatefulWidget {
  final String title;
  final List<MedicalRecord> medicalRecord;

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
                child: SoepList(widget.medicalRecord, widget.title),
              )
            : Container()
      ]),
    );
  }
}

class SoepList extends StatelessWidget {
  final String title;
  final List<MedicalRecord> medicalRecord;
  SoepList(this.medicalRecord, this.title);

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
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: medicalRecord.length,
      itemBuilder: (context, index) {
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
                        Text(
                            '${index == 0 ? 'Primera Consulta' : 'Seguimiento'}',
                            style: boldoHeadingTextStyle.copyWith(
                                fontSize: 14,
                                color: Constants.secondaryColor500)),
                        const Spacer(),
                        medicalRecord[index].prescription.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                         PrescriptionRecordScreen(medicalRecord:  medicalRecord[index])),
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
                              DateTime.parse(medicalRecord[index].startTimeDate)
                                  .toLocal()),
                          style: boldoHeadingTextStyle.copyWith(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                    ),
                    soepDescription(medicalRecord[index].soep)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
