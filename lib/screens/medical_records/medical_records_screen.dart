import 'package:boldo/models/Soep.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/utils/soep_accordion.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../constants.dart';

class MedicalRecordScreen extends StatefulWidget {
  // MedicalRecordScrenn({Key? key}) : super(key: key);

  @override
  _MedicalRecordScrennState createState() => _MedicalRecordScrennState();
}

class _MedicalRecordScrennState extends State<MedicalRecordScreen> {
  bool _dataLoaded = false;
  bool _dataLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      Response response = await dioHealthCore.get(
        "/profile/patient/encounters?includePrescriptions=false&includeSoep=true",
      );
      print(response.data);

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
          ? const Loading(title: 'Ficha Médica',)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ficha Médica',
                      textAlign: TextAlign.start,
                      style: boldoHeadingTextStyle.copyWith(fontSize: 20),
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
                      Column(
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
                              "Dolor de cabeza prolongado",
                              style: boldoHeadingTextStyle.copyWith(
                                  fontSize: 20,
                                  color: Constants.primaryColor500),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SoepAccordion('Subjetivo', soepFakeDate),
                          const Divider(
                            color: Constants.dividerAccordion,
                            thickness: 1,
                          ),
                          SoepAccordion('Objetivo', soepFakeDate),
                          const Divider(
                              color: Constants.dividerAccordion, thickness: 1),
                          SoepAccordion('Evaluación', soepFakeDate),
                          const Divider(
                              color: Constants.dividerAccordion, thickness: 1),
                          SoepAccordion('Plan', soepFakeDate),
                          const Divider(
                              color: Constants.dividerAccordion, thickness: 1),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class Loading extends StatelessWidget {
  final String title;
  const Loading({
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
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
