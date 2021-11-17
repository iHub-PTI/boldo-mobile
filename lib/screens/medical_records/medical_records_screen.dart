import 'package:boldo/models/Soep.dart';
import 'package:boldo/utils/soep_accordion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';

class MedicalRecordScreen extends StatefulWidget {
  // MedicalRecordScrenn({Key? key}) : super(key: key);

  @override
  _MedicalRecordScrennState createState() => _MedicalRecordScrennState();
}

class _MedicalRecordScrennState extends State<MedicalRecordScreen> {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ficha Médica",
                  style: boldoHeadingTextStyle.copyWith(
                      fontSize: 20, fontWeight: FontWeight.normal)),
              const Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Text("Motivo principal", style: boldoSubTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Dolor de cabeza prolongado",
                  style: boldoHeadingTextStyle.copyWith(
                      fontSize: 20, color: Constants.primaryColor500),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SoepAccordion('Subjetivo', soepFakeDate),
              const Divider(color: Constants.dividerAccordion,thickness: 1,),
              SoepAccordion('Objetivo', soepFakeDate),
               const Divider(color: Constants.dividerAccordion, thickness: 1),
              SoepAccordion('Evaluación', soepFakeDate),
               const Divider(color: Constants.dividerAccordion, thickness: 1),
              SoepAccordion('Plan', soepFakeDate),
               const Divider(color: Constants.dividerAccordion, thickness: 1),
            ],
          ),
        ),
      ),
    );
  }
}
