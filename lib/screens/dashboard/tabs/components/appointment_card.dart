import 'package:boldo/network/http.dart';
import 'package:boldo/screens/booking/booking_confirm_screen.dart';
import 'package:boldo/screens/details/appointment_details.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';

import '../../../../main.dart';

class AppointmentCard extends StatefulWidget {
  final Appointment appointment;
  final bool isInWaitingRoom;
  final bool showCancelOption;
  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.isInWaitingRoom,
    required this.showCancelOption,
  }) : super(key: key);

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool isCancelled = false;
  DateTime actualDay = DateTime.now();
  DateTime appointmentDay = DateTime.now();
  int daysDifference = 0;
  bool isToday = false;

  @override
  void initState() {
    isCancelled = widget.appointment.status!.contains('cancelled');
    actualDay = DateTime.now();
    appointmentDay = DateTime.parse(widget.appointment.start!).toLocal();
    daysDifference = daysBetween(actualDay,appointmentDay);

    setState(() {
      isToday = daysDifference == 0 &&
          !["closed", "locked"].contains(widget.appointment.status);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    String textItem = '';
    if (widget.appointment.prescriptions != null) {
      for (int i = 0; i < widget.appointment.prescriptions!.length; i++) {
        textItem = textItem +
            "${widget.appointment.prescriptions![i].medicationName}${widget.appointment.prescriptions!.length > 1 && i == 0 ? "," : ""}";
      }
    }

    return Column(
      children: [
        Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 4),
          child: InkWell(
            onTap: () {
              if (!isCancelled)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailsScreen(
                        appointment: widget.appointment,
                        isInWaitingRoom: widget.isInWaitingRoom && appointmentDay.difference(actualDay).compareTo(Duration(minutes: 15)) <= 0),
                  ),
                );
            },
            child: Container(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*Text(
                        "Marcaste esta consulta hace X dias",
                        style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.darkBlue),
                      ),*/
                      Container(),
                      widget.showCancelOption &&
                          !isCancelled &&
                          daysDifference >= 0 &&
                          !["closed", "locked"]
                              .contains(widget.appointment.status)
                          ? Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: CancelAppointmentWidget(
                          onTapCallback: (result) async {
                            if (result == 'Descartar') {
                              final response = await dio.post(
                                  !prefs.getBool("isFamily")! ?
                                    "/profile/patient/appointments/cancel/${widget.appointment.id}"
                                  : "/profile/caretaker/appointments/cancel/${widget.appointment.id}");
                              if (response.statusMessage != null) {
                                if (response.statusMessage!
                                    .contains('OK')) {
                                  setState(() {
                                    isCancelled = true;
                                  });
                                }
                              }
                            }
                          },
                        ),
                      )
                          : Container(),
                    ],
                  ),
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 54,
                          height: 54,
                          child: widget.appointment.doctor?.photoUrl == null
                              ? SvgPicture.asset(
                              widget.appointment.doctor!.gender == "female"
                                  ? 'assets/images/femaleDoctor.svg'
                                  : 'assets/images/maleDoctor.svg',
                              fit: BoxFit.cover)
                              : CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: widget.appointment.doctor!.photoUrl??'',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${getDoctorPrefix(widget.appointment.doctor!.gender!)}${widget.appointment.doctor!.familyName}",
                                style: boldoSubTextMediumStyle,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          if (widget.appointment.doctor!.specializations !=
                              null &&
                              widget.appointment.doctor!.specializations!
                                  .isNotEmpty)
                            SizedBox(
                              width: 300,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (int i = 0;
                                    i <
                                        widget.appointment.doctor!
                                            .specializations!.length;
                                    i++)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: i == 0 ? 0 : 3.0, bottom: 5),
                                        child: Text(
                                          "${widget.appointment.doctor!.specializations![i].description}${widget.appointment.doctor!.specializations!.length > 1 && i == 0 ? "," : ""}",
                                          style: boldoCorpMediumTextStyle.copyWith(color: ConstantsV2.inactiveText),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          if (isCancelled)
                            Text(
                              "Cancelado - ${DateFormat('HH:mm').format(DateTime.parse(widget.appointment.start!).toLocal())} hs ",
                              style: const TextStyle(
                                color: Constants.otherColor300,
                                fontSize: 12,
                                // fontWeight: FontWeight.bold
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      hourContainer(),
                      ShowAppoinmentTypeIcon(appointmentType: widget.appointment.appointmentType!),
                      Text(
                        widget.appointment.appointmentType == 'V' ? "Remoto" : "Presencial",
                        style: TextStyle(
                          color: widget.appointment.appointmentType == 'V' ? ConstantsV2.orange : ConstantsV2.green,
                          fontSize: 12,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget hourContainer() {
    return Container(
      width: 54,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: appointmentDay.compareTo(actualDay) <=0 ? Container(
          color: ConstantsV2.orange,
          padding: const EdgeInsets.only(left: 6.5, right: 6.5, bottom: 2, top: 2),
          child: const Text(
              "ahora",
              style: TextStyle(
                color: ConstantsV2.lightGrey,
                fontStyle: FontStyle.normal,
                fontSize: 8,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
          ),
        ) : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              appointmentDay.difference(actualDay).compareTo(Duration(minutes: 15)) <= 0 ?
                  Container(
                    padding: const EdgeInsets.only(left: 6.5, right: 6.5, bottom: 2, top: 2),
                    color: ConstantsV2.orange,
                    child: const Text("dentro de",
                    style: TextStyle(
                      color: ConstantsV2.lightGrey,
                      fontStyle: FontStyle.normal,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),),
                  ) :
              Container(
                padding: const EdgeInsets.only(left: 6.5, right: 6.5, bottom: 2, top: 2),
                color: ConstantsV2.green,
                child: Text(isToday ? "hoy" : '${DateFormat('MM/dd').format(DateTime.parse(widget.appointment.start!).toLocal())}',
                  style: const TextStyle(
                    color: ConstantsV2.lightGrey,
                    fontStyle: FontStyle.normal,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                child: isToday && appointmentDay.difference(actualDay).compareTo(Duration(minutes: 15)) <= 0 ?
                  Text("${appointmentDay.difference(actualDay).inMinutes} min",
                    style: const TextStyle(
                      color: ConstantsV2.activeText,
                      fontStyle: FontStyle.normal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ) :
                  Text("${DateFormat('HH:mm').format(appointmentDay.toLocal())}",
                    style: const TextStyle(
                      color: ConstantsV2.activeText,
                      fontStyle: FontStyle.normal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
              )
            ],
          ),
      )
    );
  }
}

class CancelAppointmentWidget extends StatelessWidget {
  final void Function(String result)? onTapCallback;
  const CancelAppointmentWidget({
    Key? key,
    required this.onTapCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        if (onTapCallback != null) {
          onTapCallback!(result.toString());
        }
      },
      child: const Icon(
        Icons.more_vert,
        color: Colors.grey,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Descartar',
          child: Container(
            height: 45,
            decoration: const BoxDecoration(color: Constants.accordionbg),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SvgPicture.asset('assets/icon/trash.svg'),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 2.0),
                  child: Text('Cancelar cita'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
