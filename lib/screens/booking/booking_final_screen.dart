import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:boldo/blocs/homeNews_bloc/homeNews_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/widgets/background.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'booking_confirm_screen.dart';

class BookingFinalScreen extends StatefulWidget {
  final Doctor doctor;
  final NextAvailability bookingDate;
  final OrganizationWithAvailabilities organization;
  BookingFinalScreen({
    Key? key,
    required this.doctor,
    required this.bookingDate,
    required this.organization,
  }) : super(key: key);

  @override
  _BookingFinalScreenState createState() => _BookingFinalScreenState();
}

class _BookingFinalScreenState extends State<BookingFinalScreen> {

  GlobalKey _columnKey = GlobalKey<FormState>();

  bool appear = false;
  int time = 0;
  Timer? _timer;

  int secondsToRedirectHome = 30;

  @override
  void initState() {
    _timer = Timer.periodic(
        const Duration(seconds: 1),
          (timer) {

          time = timer.tick;
          setState(() {

          });
          if(time == secondsToRedirectHome){
            timer.cancel();
            Provider.of<UtilsProvider>(context, listen: false)
                .setSelectedPageIndex(pageIndex: 0);
            BlocProvider.of<HomeNewsBloc>(context).add(GetNews());
            Navigator.of(context).popUntil(ModalRoute.withName('/home'));
          }
        }
    );
    super.initState();
  }

  @override
  void dispose(){
    // stop the timer in charge of updating circular progress
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SvgPicture.asset('assets/Logo.svg',
                  semanticsLabel: 'BOLDO Logo'),
            ),
          ),
          body: Stack(
            children: [
              const Background(text: "linkFamily",),
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 25, bottom: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Cita confirmada",
                                    style: boldoTitleRegularTextStyle.copyWith(color: ConstantsV2.lightest),
                                  ),
                                  const SizedBox(height: 26,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BounceInUp(
                                        from: 200,
                                        duration: const Duration(seconds: 1),
                                        child: ElasticInLeft(
                                          duration: const Duration(seconds: 1),
                                          child: Spin(
                                            spins: 0.05,
                                            duration: const Duration(milliseconds: 500),
                                            child: Spin(
                                              delay: const Duration(milliseconds: 1000),
                                              duration: const Duration(milliseconds: 1000),
                                              spins: -0.1,
                                              child: Spin(
                                                delay: const Duration(milliseconds: 2000),
                                                duration: const Duration(milliseconds: 1000),
                                                spins: 0.05,
                                                child: ImageViewTypeForm(
                                                  height: 96,
                                                  width: 96,
                                                  border: true,
                                                  url: patient.photoUrl,
                                                  gender: patient.gender,
                                                  borderColor: ConstantsV2.secondaryRegular,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8,),
                                      BounceInUp(
                                        from: 200,
                                        duration: const Duration(seconds: 1),
                                        child: ElasticInRight(
                                          duration: const Duration(seconds: 1),
                                          child: Spin(
                                            spins: -0.05,
                                            duration: const Duration(milliseconds: 500),
                                            child: Spin(
                                              delay: const Duration(milliseconds: 1000),
                                              duration: const Duration(milliseconds: 1000),
                                              spins: 0.1,
                                              child: Spin(
                                                delay: const Duration(milliseconds: 2000),
                                                duration: const Duration(milliseconds: 1000),
                                                spins: -0.05,
                                                child: ImageViewTypeForm(
                                                  height: 96,
                                                  width: 96,
                                                  border: true,
                                                  url: widget.doctor.photoUrl,
                                                  gender: widget.doctor.gender,
                                                  isPatient: false,
                                                  borderColor: ConstantsV2.secondaryRegular,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: FadeIn(
                                  duration: const Duration(milliseconds: 4000),
                                  child: Column(
                                    children: [
                                      Card(
                                        margin: EdgeInsets.zero,
                                        elevation: 0,
                                        color: ConstantsV2.lightest.withOpacity(.5),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/icon/calendar.svg',
                                                            color: ConstantsV2.inactiveText,
                                                            height: 20,
                                                          ),
                                                          const SizedBox(width: 6,),
                                                          Expanded(
                                                            child: Container(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                      "Tu consulta se marcó para el",
                                                                      style: boldoCorpMediumTextStyle.copyWith(
                                                                          color: ConstantsV2.activeText
                                                                      )
                                                                  ),
                                                                  Text(
                                                                    formatDate(
                                                                      DateTime.parse(
                                                                          widget.bookingDate.availability?? DateTime.now().toString()
                                                                      ),
                                                                      [d, ' de ', MM, ' a las ', HH, ':',nn, ' ', am],
                                                                      locale: const SpanishDateLocale(),
                                                                    ),
                                                                    style: boldoCorpMediumBlackTextStyle.copyWith(
                                                                        color: ConstantsV2.activeText
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 16,),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/icon/stethoscope.svg',
                                                            color: ConstantsV2.inactiveText,
                                                            height: 20,
                                                          ),
                                                          const SizedBox(width: 6,),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  widget.doctor.gender == 'female'
                                                                      ? "Con la doctora"
                                                                      : "Con el doctor",
                                                                  style: boldoCorpMediumTextStyle.copyWith(
                                                                      color: ConstantsV2.activeText
                                                                  ),
                                                                ),
                                                                Wrap(
                                                                  children: [
                                                                    Text(
                                                                      "${widget.doctor.givenName?.split(' ')[0]?? ''} "
                                                                          "${widget.doctor.familyName?.split(' ')[0]?? ''}, "
                                                                      ,
                                                                      style: boldoCorpMediumBlackTextStyle.copyWith(
                                                                          color: ConstantsV2.activeText
                                                                      ),
                                                                    ),
                                                                    for (int i = 0;
                                                                    i <
                                                                        widget.doctor
                                                                            .specializations!.length;
                                                                    i++)
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            right: i == 0 ? 0 : 3.0, bottom: 5),
                                                                        child: Text(
                                                                          "${widget.doctor.specializations![i].description}${widget.doctor.specializations!.length-1 != i  ? ", " : ""}",
                                                                          style: boldoCorpMediumBlackTextStyle.copyWith(color: ConstantsV2.activeText),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  color: ConstantsV2.lightest.withOpacity(.9),
                                                  padding: const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                ShowAppoinmentTypeIcon(appointmentType: widget.bookingDate.appointmentType?? 'A'),
                                                                const SizedBox(width: 8,),
                                                                Container(
                                                                  child: Expanded(
                                                                    child:  Text(
                                                                        (widget.bookingDate.appointmentType?? 'A') == 'A'?
                                                                        "Esta consulta será realizada en persona en el ${widget.organization.nameOrganization}."
                                                                            : "Esta consulta será realizada de forma remota a través de esta aplicación.",
                                                                        style: boldoCorpMediumTextStyle.copyWith(
                                                                            color: ConstantsV2.activeText
                                                                        )
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                      ),
                                      Card(
                                        margin: EdgeInsets.zero,
                                        elevation: 0,
                                        color: ConstantsV2.lightest.withOpacity(.9),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(16)
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                            child: Column(
                                              children: [

                                              ],
                                            )
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // TODO: button to edit the appointment reservation
                              Container(),
                              CircularStepProgressIndicator(
                                height: 55,
                                width: 55,
                                stepSize: 4,
                                totalSteps: 100,
                                currentStep: time*100~/secondsToRedirectHome,
                                selectedColor: ConstantsV2.grayLightAndClear,
                                padding: 0,
                                child: ElevatedButton(
                                  //  style: style1,
                                  onPressed: () {
                                    Provider.of<UtilsProvider>(context, listen: false)
                                        .setSelectedPageIndex(pageIndex: 0);
                                    BlocProvider.of<HomeNewsBloc>(context).add(GetNews());
                                    Navigator.of(context).popUntil(ModalRoute.withName('/home'));
                                  },
                                  child: SvgPicture.asset(
                                    'assets/icon/home.svg',
                                    height: 20,
                                  ),
                                ),
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
