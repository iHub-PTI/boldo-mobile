import 'package:boldo/blocs/passport_bloc/passportBloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/screens/passport/passport_detail_screen.dart';
import 'package:boldo/screens/passport/vaccine_filter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/UserVaccinate.dart';
import '../../utils/loading_helper.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/tabs/components/data_fetch_error.dart';

// this class show my passport tab
class PassportTab extends StatefulWidget {
  // class constructor
  PassportTab({Key? key}) : super(key: key);

  // initial state for this Stateful
  @override
  _PassportTabState createState() => _PassportTabState();
}

// this class define the passport state
class _PassportTabState extends State<PassportTab> {
  // function for show qr alert
  void showQrOptionsDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext cxt) {
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: MediaQuery.of(context).size.width >
                    MediaQuery.of(context).size.height
                ? const EdgeInsets.all(10)
                : const EdgeInsets.all(16),
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: MediaQuery.of(context).size.width >
                        MediaQuery.of(context).size.height
                    ? const EdgeInsets.all(10)
                    : const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // this to make sure it's empty
                        vaccineListQR!.clear();
                        for (var i = 0; i < diseaseUserList!.length; i++) {
                          // and then, add all elements
                          vaccineListQR!.add(diseaseUserList![i]);
                        }
                        Navigator.pushNamed(context, '/user_qr_detail');
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side:
                              const BorderSide(color: Colors.white70, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SvgPicture.asset('assets/icon/select_all.svg'),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  VaccineFilter(),
                            ));
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side:
                              const BorderSide(color: Colors.white70, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            SvgPicture.asset('assets/icon/select_to_show.svg'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    BlocProvider.of<PassportBloc>(context).add(GetUserDiseaseList());
    super.initState();
  }

  bool _isloading = false;
  int _failedConectionCounter = 0;

  // principal view
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
        body: BlocListener<PassportBloc, PassportState>(
          listener: (context, state) {
            if (state is Failed || state is Success) {
              if (state is Failed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.response),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                _failedConectionCounter++;
              } else {
                _failedConectionCounter = 0;
              }
              setState(() {
                _isloading = false;
              });
            }
            if (state is Loading) {
              setState(() {
                _isloading = true;
              });
            }
          },
          child: Stack(children: [
            BlocBuilder<PassportBloc, PassportState>(
              builder: (context, state) {
                if (state is Failed) {
                  return Align(
                      alignment: Alignment.center,
                      child: DataFetchErrorWidget(
                        retryCallback: () async {
                          if (_failedConectionCounter >= 3) {
                            _failedConectionCounter = 0;
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashboardScreen(),
                                ),
                                (route) => false);
                          } else {
                            BlocProvider.of<PassportBloc>(context)
                                .add(GetUserDiseaseList());
                          }
                        },
                      ));
                }
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      // starts at the top of the page
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // button and label for go to back
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
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
                                'Pasaporte',
                                style: boldoHeadingTextStyle.copyWith(
                                    fontSize: 20),
                              )),
                        ),
                        // label and options for download vaccination
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 32, right: 16, top: 10),
                          child: Row(
                            children: [
                              // Inmunizaciones label
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Inmunizaciones',
                                        style: boldoHeadingTextStyle.copyWith(
                                            fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // get QR whit an alert
                              diseaseUserList != null && !diseaseUserList!.isEmpty
                                ? GestureDetector(
                                  onTap: () => showQrOptionsDialog(context),
                                  child: Container(
                                    height: 44,
                                    width: 44,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SvgPicture.asset(
                                        'assets/icon/qrcode.svg',
                                        color: Colors.grey[800],
                                        height: 14,
                                      ),
                                    ),
                                  ),
                                )
                                : Container(),
                              const SizedBox(width: 4),
                              // pdf download
                              diseaseUserList != null && !diseaseUserList!.isEmpty
                                ? GestureDetector(
                                  // add bloc code
                                  onTap: () {
                                    BlocProvider.of<PassportBloc>(context)
                                      .add(GetUserVaccinationPdfPressed(pdfFromHome: true));
                                  },
                                  child: Container(
                                    height: 44,
                                    width: 44,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SvgPicture.asset(
                                        'assets/icon/document-text.svg',
                                        color: Colors.grey[800],
                                        height: 14,
                                      ),
                                    ),
                                  ),
                                )
                                : Container(),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  BlocProvider.of<PassportBloc>(context)
                                      .add(GetUserDiseaseListSync());
                                },
                                child: Container(
                                  height: 44,
                                  width: 44,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SvgPicture.asset(
                                      'assets/icon/refresh.svg',
                                      color: Colors.grey[800],
                                      height: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // vaccine list
                        diseaseUserList != null
                            ? !diseaseUserList!.isEmpty
                              ? VaccinateCard()
                              : !_isloading
                                  ? Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                            'assets/images/empty_studies.svg'),
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'No existee registro vacunatorio suyo.',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  253, 165, 125, 1),
                                              fontSize: 18,
                                              fontFamily: 'Montserrat'
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : Text('')
                            : !_isloading
                                ? Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                            'assets/images/empty_studies.svg'),
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'No poseemos registro suyo, puede sincronizar sus datos con los del MSPyBS arriba.',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  253, 165, 125, 1),
                                              fontSize: 18,
                                              fontFamily: 'Montserrat'
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const Text('')
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_isloading)
              Align(
                  alignment: Alignment.center,
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white.withOpacity(0.3),
                      child: const LoadingHelper()))
          ]),
        ));
  }
}

class VaccinateCard extends StatefulWidget {
  const VaccinateCard({
    Key? key,
  }) : super(key: key);

  @override
  State<VaccinateCard> createState() => _VaccinatedCard();
}

class _VaccinatedCard extends State<VaccinateCard> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: diseaseUserList!.length,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int indexInmunizacion) {
          return GestureDetector(
            onTap: () {
              //Todo: replace for navigation route
              // this to make sure it's empty
              vaccineListQR!.clear();
              // here we add vaccination to generate the QR url for one selection
              vaccineListQR!.add(diseaseUserList![indexInmunizacion]);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PassportDetail(
                          userVaccinate: diseaseUserList![indexInmunizacion],
                        )),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color.fromRGBO(40, 179, 187, 1),
                                  width: 8))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    diseaseUserList![indexInmunizacion]
                                        .diseaseCode,
                                    style: boldoSubTextStyle),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'fuente',
                                  style: boldoTitleBlackTextStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  MediaQuery.of(context).size.width > 410
                                      ? 'registro de vacunación\nelectrónico'
                                      : 'registro de\nvacunación\nelectrónico',
                                  style: boldoTitleBlackTextStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                          MediaQuery.of(context).size.width > 600
                              ? SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2)
                              : MediaQuery.of(context).size.width < 410
                                  ? const SizedBox(width: 20)
                                  : const SizedBox(width: 0),
                          dynamicDiseasesShow(
                              diseaseUserList![indexInmunizacion]
                                  .vaccineApplicationList!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget dynamicDiseasesShow(List<VaccineApplicationList> vaccinationList) {
    // contain s the list of dose types
    List distints = [];
    List<List<VaccineApplicationList>> vaccinationFilter = [];

    vaccinationList.forEach((element) {
      if (!distints.contains(element.vaccineName)) {
        distints.add(element.vaccineName);
      }
    });

    distints.forEach((name) {
      vaccinationFilter.add(vaccinationList
          .where((element) => element.vaccineName == name)
          .toList());
    });
// vaccinationFilter.reversed.toList()
    return Container(
        width: 188,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
              reverse: true,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: vaccinationFilter.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int indexDose) {
                return Container(
                  decoration: const BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              color: Color.fromRGBO(40, 179, 187, 1),
                              width: 2))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vaccinationFilter[indexDose][0].vaccineName}',
                          style: const TextStyle(
                            color: Color.fromRGBO(40, 179, 187, 1),
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 2),
                          itemCount:
                              vaccinationFilter[indexDose].toList().length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          reverse: true,
                          itemBuilder: (BuildContext context, int index) {
                            final disease = vaccinationFilter[indexDose][index];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  disease.dose!.contains('°')
                                      ? disease.dose!
                                      : disease.dose!.contains('1')
                                          ? '1° Dosis'
                                          : disease.dose!.contains('2')
                                              ? '2° Dosis'
                                              : (disease.dose!),
                                  style: boldoHeadingTextStyle.copyWith(
                                      fontSize: 14),
                                ),
                                // SizedBox(width: 15),
                                Text(
                                    '${DateFormat('d/M/y').format(disease.vaccineApplicationDate)}',
                                    style: boldoHeadingTextStyle.copyWith(
                                        fontSize: 14)),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ));
  }
}
