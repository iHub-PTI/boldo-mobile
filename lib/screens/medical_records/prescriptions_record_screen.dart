import 'package:boldo/blocs/prescription_bloc/prescriptionBloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';

import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/observers/navigatorObserver.dart';
import 'package:boldo/screens/appointments/components/showAppointmentOrigin.dart';
import 'package:boldo/screens/appointments/medicalRecordScreen.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/prescriptions/components/medication_name.dart';
import 'package:boldo/screens/studies_orders/ProfileDescription.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrescriptionRecordScreen extends StatefulWidget {
  const PrescriptionRecordScreen({
    Key? key,
    required this.medicalRecordId,
    required this.doctor,
  }) : super(key: key);

  final String medicalRecordId;
  final Doctor doctor;

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionRecordScreen> {

  MedicalRecord? medicalRecord;
  bool fromAppointmentDetail = AppNavigatorObserver.containRoute(routeName: (MedicalRecordsScreen).toString()) ;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<PrescriptionBloc>(context).add(GetPrescription(id: widget.medicalRecordId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: SvgPicture.asset('assets/Logo.svg',
                semanticsLabel: 'BOLDO Logo'),
          ),
        ),
        body: BlocListener<PrescriptionBloc, PrescriptionState>(
          listener: (context, state) {
            if(state is PrescriptionLoaded){
              medicalRecord = state.prescription;
            }else if(state is FailedLoadPrescription){
              emitSnackBar(
                  context: context,
                  text: state.response,
                  status: ActionStatus.Fail
              );
            }
          },
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 24,
                ),
                BackButtonLabel(
                  labelText: 'Detalles de la receta',
                ),
                const SizedBox(
                  height: 16,
                ),
                BlocBuilder<PrescriptionBloc, PrescriptionState>(builder: (context, state){
                  if( state is PrescriptionLoaded){
                    return Flexible(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      shadowRegular,
                                    ],
                                    color: ConstantsV2.lightest
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ProfileDescription(
                                              doctor: widget.doctor,
                                              type: "doctor",
                                              border: false,
                                              horizontalDescription: true,
                                              padding: EdgeInsets.zero,
                                            ),
                                            Container(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "Emitido el",
                                                      style: boldoCorpSmallSTextStyle.copyWith(
                                                          color: ConstantsV2.inactiveText
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: BlocBuilder<PrescriptionBloc, PrescriptionState>(
                                                        builder: (context, state) {
                                                          // in case of loading data
                                                          if(state is LoadingPrescription){
                                                            return Text(
                                                              'Cargando',
                                                              style: boldoSubTextMediumStyle.copyWith(
                                                                  color: ConstantsV2.inactiveText
                                                              ),
                                                            );
                                                          }else {
                                                            // show if not loading
                                                            return Text(
                                                              '${formatDate(
                                                                DateTime.parse(medicalRecord?.startTimeDate ??
                                                                    DateTime.now().toString()),
                                                                [d, '/', m, '/', yyyy],
                                                              )}',
                                                              style: boldoSubTextMediumStyle.copyWith(
                                                                  color: ConstantsV2.inactiveText
                                                              ),
                                                            );
                                                          }
                                                        }
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8,),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          'Diagnóstico:',
                                          style: CorpPMediumTextStyle.copyWith(
                                              color: ConstantsV2.darkBlue
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          medicalRecord?.diagnosis?? 'Sin diagnóstico',
                                          style: boldoCorpMediumWithLineSeparationLargeTextStyle.copyWith(
                                              color: ConstantsV2.darkBlue
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8,),
                                      if(!fromAppointmentDetail)
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ShowAppointmentOrigin(
                                              encounterId: medicalRecord?.id?? '0',
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                )
                            ),
                            Flexible(
                              child: content(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }else if(state is LoadingPrescription){
                    return Container(
                        child: const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                              backgroundColor: Constants.primaryColor600,
                            )
                        )
                    );
                  }else if(state is FailedLoadPrescription){
                    return Container(
                        child: DataFetchErrorWidget(retryCallback: () => BlocProvider.of<PrescriptionBloc>(context).add(GetPrescription(id: widget.medicalRecordId)) ) );
                  }else{
                    return Container();
                  }
                }
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget content(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: 16,
            ),
            child: const Text(
              "Medicamentos",
              style: boldoHeadingTextStyle,
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: ShapeDecoration(
                color: ConstantsV2.lightest,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(width: 0.50, color: Color(0xFFF7F7F7)),
                ),
                shadows: [
                  shadowRegular,
                ],
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int i){
                  return Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MedicationName(
                          prescription: medicalRecord?.prescription?[i]?? Prescription(),
                          spacing: 11,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              medicalRecord
                                  ?.prescription?[i].instructions?? 'Sin instrucciones',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index){
                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    width: double.infinity,
                    color: const Color(0xffE5E7EB),
                    height: 1,
                  );
                },
                itemCount: medicalRecord?.prescription?.length?? 0,
              ),
            ),
          ),

        ],
      ),
    );
  }


}

@deprecated
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
