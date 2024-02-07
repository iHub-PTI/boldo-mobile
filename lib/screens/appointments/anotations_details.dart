import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/screens/appointments/medicalRecordScreen.dart';
import 'package:boldo/screens/studies_orders/ProfileDescription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnnotationsDetails extends StatelessWidget {
  final MedicalRecord? medicalRecord;
  final Appointment? appointment;

  AnnotationsDetails({
    this.medicalRecord,
    this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Notas médicas',
                    style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            Expanded(
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
                              'Motivo principal',
                              style: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.inactiveText),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                  medicalRecord?.mainReason ?? '',
                                  style: boldoCorpMediumBlackTextStyle
                                      .copyWith(
                                      color: ConstantsV2.darkBlue)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            shadowRegular
                          ],
                        ),
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // doctor and patient profile
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // doctor
                                  ProfileDescription(
                                      doctor: appointment?.doctor,
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
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  shadowRegular
                                ],
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
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
                                          Text(
                                              'Notas',
                                              style: boldoCardHeadingTextStyle.copyWith(
                                                  color: ConstantsV2.activeText,
                                                  fontSize: 14
                                              )
                                          )
                                        ],
                                      ),
                                    ),
                                    SoepAccordion(
                                        title: Constants.evaluation,
                                        medicalRecord: medicalRecord!
                                    ),
                                    SoepAccordion(
                                        title: Constants.plan,
                                        medicalRecord: medicalRecord
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                    ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


}