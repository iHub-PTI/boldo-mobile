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

import 'booking_confirm_screen.dart';

class BookingFinalScreen extends StatefulWidget {
  final Doctor doctor;
  final NextAvailability bookingDate;
  final Organization organization;
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
              CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "turno marcado",
                                  style: boldoTitleRegularTextStyle.copyWith(color: ConstantsV2.lightest),
                                ),
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
                                                height: 170,
                                                width: 170,
                                                border: true,
                                                url: patient.photoUrl,
                                                gender: patient.gender,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
                                                height: 170,
                                                width: 170,
                                                border: true,
                                                url: widget.doctor.photoUrl,
                                                gender: widget.doctor.gender,
                                                isPatient: false,
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
                                                        Container(
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
                                                                  [d, ' de ', MM, ' a las ', hh, ':',nn, ' ', am],
                                                                  locale: const SpanishDateLocale(),
                                                                ),
                                                                style: boldoCorpMediumBlackTextStyle.copyWith(
                                                                    color: ConstantsV2.activeText
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16,),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/icon/stethoscope.svg',
                                                          color: ConstantsV2.inactiveText,
                                                          height: 20,
                                                        ),
                                                        const SizedBox(width: 6,),
                                                        Container(
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
                                                              Text(
                                                                "${widget.doctor.givenName?.split(' ')[0]?? ''} "
                                                                    "${widget.doctor.familyName?.split(' ')[0]?? ''}, "
                                                                    "${widget.doctor.specializations?.first.description?? ''}",
                                                                style: boldoCorpMediumBlackTextStyle.copyWith(
                                                                    color: ConstantsV2.activeText
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
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
                                                                      "Esta consulta será realizada en persona en el ${widget.organization.name}."
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
                          Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // TODO: button to edit the appointment reservation
                                  Container(),
                                  ElevatedButton(
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
                                ],
                              )
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
    );
  }
}
