import 'package:boldo/blocs/download_prescriptions_bloc/download_prescriptions_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/screens/medical_records/prescriptions_record_screen.dart';
import 'package:boldo/screens/studies_orders/ProfileDescription.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/card_button.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'medication_name.dart';

class PrescriptionCard extends StatelessWidget{

  final int maxPrescriptionShow = 4;

  final Appointment appointment;

  PrescriptionCard({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    DateTime prescriptionDate = DateTime.parse(
        appointment.start?? DateTime.now()
            .toString()).toLocal();

    int daysDifference = daysBetween(prescriptionDate,
        DateTime.now()
    );

    return BlocProvider<DownloadPrescriptionsBloc>(
      create: (BuildContext context) => DownloadPrescriptionsBloc(),
      child: Container(
        decoration: cardDecoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PrescriptionRecordScreen(
                          medicalRecordId:
                          appointment.id?? '',
                          doctor: appointment.doctor?? Doctor(),
                        ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Text(
                                "Recetado el ${DateFormat('dd/MM/yyyy').format(prescriptionDate)}",
                                style: regularText.copyWith(
                                  color: ConstantsV2.darkBlue,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                passedDays(daysDifference, showPrefixText: false, showDateFormat: false),
                                style: regularText.copyWith(
                                  color: ConstantsV2.inactiveText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 8,
                            childAspectRatio: 167/28,
                            crossAxisCount: 2,
                          ),
                          itemCount: (appointment.prescriptions?.length?? 0) >= maxPrescriptionShow ? maxPrescriptionShow: appointment.prescriptions?.length?? 0 ,
                          itemBuilder: (BuildContext context, int index){
                            if(index == (maxPrescriptionShow-1) && (appointment.prescriptions?.length?? 0) >= maxPrescriptionShow)
                              return Container(
                                padding: const EdgeInsets.all(4),
                                child: morePrescription(
                                  moreQuantity: (appointment.prescriptions?.length?? 0) - (maxPrescriptionShow-1),
                                ),
                              );

                            return Container(
                              padding: const EdgeInsets.all(4),
                              child: MedicationName(
                                prescription: appointment.prescriptions?[index]?? Prescription(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Container(
                              child: ProfileDescription(
                                type: 'doctor',
                                doctor: appointment.doctor,
                                height: 27,
                                width: 27,
                                border: false,
                                padding: EdgeInsets.zero,
                                horizontalDescription: true,
                                nameStyle: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                                nameColor: ConstantsV2.activeText,
                                descriptionStyle: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                                descriptionColor: ConstantsV2.inactiveText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions(
                    context: context,
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }

  Widget actions({required BuildContext context}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BlocBuilder<DownloadPrescriptionsBloc, DownloadPrescriptionsState>(
          builder: (BuildContext context, state){
            if(state is Loading){
              return loadingStatus();
            }else{
              return CardButton(
                function: (){
                  BlocProvider.of<DownloadPrescriptionsBloc>(context).add(
                    DownloadPrescriptions(
                      listOfIds: [appointment.prescriptions?.first.encounterId],
                      context: context,
                    ),
                  );
                },
                child: Container(
                  child: Text(
                    "Indicaciones",
                    style: bigButton,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget morePrescription({required int moreQuantity}){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture
            .asset(
          'assets/icon/add.svg',
          color: ConstantsV2.darkBlue,
          width: 15,
        ),
        const SizedBox(
            width:
            4),
        Flexible(
          child: Text(
            "$moreQuantity medicamentos",
            style: medicationTextStyle,
            overflow:
            TextOverflow
                .ellipsis,
          ),
        ),
      ],
    );
  }

}