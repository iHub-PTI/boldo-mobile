import 'package:boldo/blocs/prescription_bloc/prescriptionBloc.dart';
import 'package:boldo/constants.dart';

import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrescriptionRecordScreen extends StatefulWidget {
  const PrescriptionRecordScreen({required this.medicalRecordId}) : super();

  final String medicalRecordId;

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionRecordScreen> {

  MedicalRecord? medicalRecord;

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
        body: Background(
          child: BlocListener<PrescriptionBloc, PrescriptionState>(
            listener: (context, state) {
              if(state is PrescriptionLoaded){
                medicalRecord = state.prescription;
              }else if(state is FailedLoadPrescription){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.response!),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: BlocBuilder<PrescriptionBloc, PrescriptionState>(builder: (context, state){
              if( state is PrescriptionLoaded){
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
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
                          'Detalles de la receta',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Diagnóstico",
                                style: boldoHeadingTextStyle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                medicalRecord?.diagnosis ?? '',
                                style: boldoSubTextStyle.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Indicaciones",
                                style: boldoHeadingTextStyle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                medicalRecord?.instructions ?? '',
                                style: boldoSubTextStyle.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 26),
                              for (int i = 0;
                              i < medicalRecord!.prescription!.length;
                              i++)
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Medicamento ${i + 1}",
                                          style: boldoHeadingTextStyle.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 0,
                                          top: 7,
                                          left: 0,
                                          right: 0,
                                        ),
                                        width: double.infinity,
                                        color: const Color(0xffE5E7EB),
                                        height: 1,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Nombre",
                                        style: boldoHeadingTextStyle,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        medicalRecord?.prescription![i].medicationName?? '',
                                        style:
                                        boldoSubTextStyle.copyWith(fontSize: 16),
                                      ),
                                      if (medicalRecord
                                          ?.prescription![i].instructions !=
                                          null)
                                        Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 24),
                                              const Text(
                                                "Instrucciones",
                                                style: boldoHeadingTextStyle,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                medicalRecord
                                                    ?.prescription![i].instructions??'',
                                                style: boldoSubTextStyle.copyWith(
                                                    fontSize: 16),
                                              ),
                                            ]),
                                      const SizedBox(height: 24),
                                    ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }else if(State is LoadingPrescription){
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
          )
        ));
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
