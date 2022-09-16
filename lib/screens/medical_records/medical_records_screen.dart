import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/medical_records/medical_records_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../main.dart';

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
      if(prefs.getBool(isFamily)?? false)
        allMedicalData = [];
      else
        await getMedicalRecords();
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Ficha Médica',
                      textAlign: TextAlign.start,
                      style: boldoHeadingTextStyle.copyWith(fontSize: 20),
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
                    allMedicalData.isEmpty
                    ? const EmptyStateV2(
                      picture: "feed_empty.svg",
                      textTop: "Nada para mostrar",
                    )
                    : SizedBox(
                      height: MediaQuery.of(context).size.height - 260,
                      child: ListView.separated(
                        itemCount: allMedicalData.length,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.transparent,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MedicalRecordsDetails(
                                        encounterId: allMedicalData[index].id)),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 96,
                                  width: 64,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                    ),
                                    color: Color(0xffFFFBF6),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset('assets/icon/file.svg',
                                          fit: BoxFit.cover),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${allMedicalData[index].startTimeDate != null ? DateFormat('MMM').format(DateTime.parse(allMedicalData[index].startTimeDate!).toLocal()) : ''}",
                                        style: const TextStyle(
                                          color: Color(0xffDF6D51),
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        "${allMedicalData[index].startTimeDate != null ? DateFormat('dd').format(DateTime.parse(allMedicalData[index].startTimeDate!).toLocal()) : ""}",
                                        style: const TextStyle(
                                          color: Color(0xffDF6D51),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allMedicalData[index].mainReason ?? '',
                                      style: const TextStyle(
                                        color: Constants.extraColor400,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      width: 200,
                                      child: Text(
                                        allMedicalData[index].diagnosis ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Constants.extraColor300,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
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
