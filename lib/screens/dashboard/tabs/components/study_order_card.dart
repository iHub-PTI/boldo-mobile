import 'dart:async';

import 'package:boldo/blocs/study_order_bloc/studyOrder_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/studies_orders/StudyOrderScreen.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudyOrderCard extends StatefulWidget {
  final StudyOrder studyOrder;
  const StudyOrderCard({
    Key? key,
    required this.studyOrder,
  }) : super(key: key);

  @override
  State<StudyOrderCard> createState() => _StudyOrderCardCardState();
}

class _StudyOrderCardCardState extends State<StudyOrderCard> {
  DateTime actualDay = DateTime.now();
  DateTime orderDay = DateTime.now();
  int daysDifference = 0;
  int minutesToUpdate = 0;
  Timer? timer;

  @override
  void didUpdateWidget(StudyOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.studyOrder != oldWidget.studyOrder) {
      actualDay = DateTime.now();
      orderDay = DateTime.parse(widget.studyOrder.authoredDate ??
              DateTime.now().toIso8601String())
          .toLocal();
      daysDifference = daysBetween(actualDay, orderDay);
    }
    timer?.cancel();
    _updateWaitingRoom(0);
  }

  @override
  void initState() {
    actualDay = DateTime.now();
    orderDay = DateTime.parse(
            widget.studyOrder.authoredDate ?? DateTime.now().toIso8601String())
        .toLocal();
    daysDifference = daysBetween(actualDay, orderDay);
    super.initState();
    _updateWaitingRoom(0);
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  // asynchronous task to update the days between actualDay and OrderDay
  void _updateWaitingRoom(int minutes) async {
    timer = Timer.periodic(Duration(minutes: minutes), (Timer timer) {
      actualDay = DateTime.now();
      if (mounted)
        setState(() {
          // get days minutes difference and divide by an day in minutes (1140 minutes)
          // round to int
          daysDifference = (actualDay.difference(orderDay).inMinutes) ~/ 1140;

          // next day time to update view
          DateTime nextDay = DateTime.now().add(const Duration(days: 1));
          // remove hours, minutes and seconds
          nextDay = DateTime(nextDay.year, nextDay.month, nextDay.day);
          minutesToUpdate = nextDay.difference(DateTime.now()).inMinutes;
          timer.cancel();
          _updateWaitingRoom(minutesToUpdate);
        });
      // TODO: condition to remove an StudyOrder from news
      //if(condition) {
      //  timer.cancel();
      //  // notify at home to delete this StudyOrder
      //  BlocProvider.of<HomeNewsBloc>(context).add(DeleteNews(news: widget.studyOrder));
      //}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 4),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Estudios pendientes",
                            style: boldoCorpSmallTextStyle.copyWith(
                                color: ConstantsV2.darkBlue),
                          ),
                          Text(
                            passedDays(daysDifference, showPrefixText: true),
                            style: boldoCorpSmallTextStyle.copyWith(
                                color: ConstantsV2.veryLightBlue),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: ClipOval(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: widget.studyOrder.doctor?.photoUrl ==
                                        null
                                    ? SvgPicture.asset(
                                        widget.studyOrder.doctor!.gender ==
                                                "female"
                                            ? 'assets/images/femaleDoctor.svg'
                                            : 'assets/images/maleDoctor.svg',
                                        fit: BoxFit.cover)
                                    : CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: widget
                                                .studyOrder.doctor!.photoUrl ??
                                            '',
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                Padding(
                                          padding: const EdgeInsets.all(26.0),
                                          child: LinearProgressIndicator(
                                            value: downloadProgress.progress,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                        Color>(
                                                    Constants.primaryColor400),
                                            backgroundColor:
                                                Constants.primaryColor600,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${getDoctorPrefix(widget.studyOrder.doctor!.gender!)}${widget.studyOrder.doctor?.givenName?.split(" ")[0]?? ''} ${widget.studyOrder.doctor?.familyName?.split(" ")[0]?? ''}",
                                      style: boldoSubTextMediumStyle,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                if (widget.studyOrder.doctor!.specializations !=
                                    null &&
                                    widget.studyOrder.doctor!.specializations!
                                        .isNotEmpty)
                                  Wrap(
                                    children: [
                                      for (int i = 0;
                                      i <
                                          widget.studyOrder.doctor!
                                              .specializations!.length;
                                      i++)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: i == 0 ? 0 : 3.0, bottom: 5),
                                          child: Text(
                                            "${widget.studyOrder.doctor!.specializations![i].description}${widget.studyOrder.doctor!.specializations!.length-1 != i  ? ", " : ""}",
                                            style: boldoCorpMediumTextStyle.copyWith(color: ConstantsV2.inactiveText),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _ordersIconsContainer(),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            child: GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudyOrderScreen(
                                        callFromHome: true,
                                        encounterId:
                                            widget.studyOrder.encounterId),
                                  ),
                                );
                                BlocProvider.of<StudyOrderBloc>(context).add(InitialEventStudyOrder());
                              },
                              child: Card(
                                  margin: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5)),
                                  ),
                                  color: ConstantsV2.orange.withOpacity(0.10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 7),
                                    child: const Text("ver"),
                                  )),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget _ordersIconsContainer() {
    return Container(
        child: Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Card(
                  clipBehavior: Clip.antiAlias,
                  color: ConstantsV2.orange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    child: Text(
                        "${widget.studyOrder.serviceRequests?.length ?? 0}"),
                  )),
              widget.studyOrder.serviceRequests != null
                ? widget.studyOrder.serviceRequests!.length > 0
                  ? Text(
                    widget.studyOrder.serviceRequests!.length == 1 ? "orden" : "órdenes",
                    style: boldoCorpMediumTextStyle.copyWith(
                        color: ConstantsV2.darkBlue),
                  )
                  : Container() 
                : Container(),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                if (widget.studyOrder.serviceRequests!
                    .any((element) => element.category == 'Laboratory'))
                  Container(
                    padding: const EdgeInsets.all(3),
                    child: SvgPicture.asset(
                      'assets/icon/lab-dark.svg',
                      height: 18,
                      width: 18,
                      color: ConstantsV2.veryLightBlue,
                    ),
                  ),
                if (widget.studyOrder.serviceRequests!
                    .any((element) => element.category == 'Diagnostic Imaging'))
                  Container(
                    padding: const EdgeInsets.all(3),
                    child: SvgPicture.asset(
                      'assets/icon/image-dark.svg',
                      height: 18,
                      width: 18,
                      color: ConstantsV2.veryLightBlue,
                    ),
                  ),
                if (widget.studyOrder.serviceRequests!.any((element) {
                  return element.category != 'Diagnostic Imaging' &&
                      element.category != 'Laboratory';
                }))
                  Container(
                    padding: const EdgeInsets.all(3),
                    child: SvgPicture.asset(
                      'assets/icon/other.svg',
                      height: 18,
                      width: 18,
                      color: ConstantsV2.veryLightBlue,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
