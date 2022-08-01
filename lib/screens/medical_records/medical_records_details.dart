import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/utils/soep_accordion.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../constants.dart';

class MedicalRecordsDetails extends StatefulWidget {
  final encounterId;

  const MedicalRecordsDetails({@required this.encounterId});

  @override
  _MedicalRecordDetailState createState() => _MedicalRecordDetailState();
}

class _MedicalRecordDetailState extends State<MedicalRecordsDetails> {
  bool _dataLoaded = false;
  bool _dataLoading = true;
  List<MedicalRecord> allMedicalData = [];
  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      Response response = await dio.get(
          "profile/patient/relatedEncounters/${widget.encounterId}?includePrescriptions=true&includeSoep=true");
   
      allMedicalData = List<MedicalRecord>.from(
          response.data["items"].map((i) => MedicalRecord.fromJson(i)));
      
      allMedicalData.sort((a, b) => a.startTimeDate!.compareTo(b.startTimeDate!));
      setState(() {
        _dataLoading = false;
        _dataLoaded = true;
      });
    } on DioError catch (exception, stackTrace) {
      print(exception);
      setState(() {
        _dataLoading = false;
        _dataLoaded = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);
      setState(() {
        _dataLoading = false;
        _dataLoaded = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
  }

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
      body: _dataLoading == true
          ? const Loading(
              title: 'Ficha Médica',
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
                          'Ficha Médica',
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
                                  allMedicalData.first.mainReason??'',
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
                                  medicalRecord: allMedicalData),
                              const Divider(
                                color: Constants.dividerAccordion,
                                thickness: 1,
                              ),
                              SoepAccordion(
                                  title: Constants.objective,
                                  medicalRecord: allMedicalData),
                              const Divider(
                                  color: Constants.dividerAccordion,
                                  thickness: 1),
                              SoepAccordion(
                                  title: Constants.evaluation,
                                  medicalRecord: allMedicalData),
                              const Divider(
                                  color: Constants.dividerAccordion,
                                  thickness: 1),
                              SoepAccordion(
                                  title: Constants.plan,
                                  medicalRecord: allMedicalData),
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
}

class Loading extends StatelessWidget {
  final String title;
  const Loading({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 25,
              color: Constants.extraColor400,
            ),
            label: Text(
              title,
              style: boldoHeadingTextStyle.copyWith(fontSize: 20),
            ),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 48.0),
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
              backgroundColor: Constants.primaryColor600,
            ),
          ),
        ),
      ],
    );
  }
}
