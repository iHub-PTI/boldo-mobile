import 'package:boldo/network/http.dart';
import 'package:boldo/screens/booking/booking_confirm_screen.dart';
import 'package:boldo/screens/details/appointment_details.dart';
import 'package:boldo/screens/details/prescription_details.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';

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
  @override
  void initState() {
    isCancelled = widget.appointment.status!.contains('cancelled');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final actualDay = DateTime.now();
    final appointmentDay = DateTime.parse(widget.appointment.start!);
    int daysDifference = DateTime.parse(widget.appointment.start!)
        .toLocal()
        .difference(actualDay)
        .inDays;
    if (actualDay.month == appointmentDay.month) {
      daysDifference = appointmentDay.day - actualDay.day;
    }
    bool isToday = daysDifference == 0 &&
        !["closed", "locked"].contains(widget.appointment.status);

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
          elevation: 1.4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
          child: InkWell(
            onTap: () {
              if (!isCancelled)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailsScreen(
                        appointment: widget.appointment,
                        isInWaitingRoom: widget.isInWaitingRoom),
                  ),
                );
            },
            child: Row(
              children: [
                Container(
                  height: 96,
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                    color: isToday
                        ? Constants.primaryColor500
                        : const Color(0xffF3FAF7),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(
                            DateTime.parse(widget.appointment.start!)
                                .toLocal()),
                        style: TextStyle(
                          color: isToday
                              ? Constants.extraColor100
                              : Constants.primaryColor500,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        DateFormat('dd').format(
                            DateTime.parse(widget.appointment.start!)
                                .toLocal()),
                        style: TextStyle(
                          color: isToday
                              ? Constants.extraColor100
                              : Constants.primaryColor500,
                          fontSize: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ShowAppoinmentTypeIcon(
                          appointmentType: widget.appointment.appointmentType!,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${getDoctorPrefix(widget.appointment.doctor!.gender!)}${widget.appointment.doctor!.familyName}",
                              style: const TextStyle(
                                color: Constants.extraColor400,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            widget.showCancelOption && !isCancelled && daysDifference >= 0
                                ? Padding(
                                  padding: const EdgeInsets.only(right:4.0),
                                  child: CancelAppointmentWidget(
                                      onTapCallback: (result) async {
                                        if (result == 'Descartar') {
                                          final response = await dio.post(
                                              "/profile/patient/appointments/cancel/${widget.appointment.id}");
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
                                : Container()
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
                                        style: boldoSubTextStyle,
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
                        if (isToday && !isCancelled)
                          Column(
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "¡Hoy! - ${DateFormat('HH:mm').format(DateTime.parse(widget.appointment.start!).toLocal())} hs",
                                style: const TextStyle(
                                  color: Constants.primaryColor600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        if (daysDifference > 0 && !isCancelled)
                          Column(
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "En $daysDifference ${daysDifference > 1 ? 'días' : 'dia'}  - ${DateFormat('HH:mm').format(DateTime.parse(widget.appointment.start!).toLocal())} hs",
                                style: const TextStyle(
                                  color: Constants.otherColor200,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    flex: 5),
              ],
            ),
          ),
        ),
        if (widget.appointment.prescriptions != null &&
            widget.appointment.prescriptions!.isNotEmpty)
          Card(
            elevation: 1.4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
            child: InkWell(
              onTap: () {
                if (!isCancelled)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrescriptionDetailsScreen(
                        appointment: widget.appointment,
                      ),
                    ),
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
                          DateFormat('MMM').format(
                              DateTime.parse(widget.appointment.start!)
                                  .toLocal()),
                          style: const TextStyle(
                            color: Color(0xffDF6D51),
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DateFormat('dd').format(
                              DateTime.parse(widget.appointment.start!)
                                  .toLocal()),
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
                      const Text(
                        "Receta",
                        style: TextStyle(
                          color: Constants.extraColor400,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      if (widget.appointment.prescriptions != null &&
                          widget.appointment.prescriptions!.isNotEmpty)
                        Container(
                          width: 200,
                          child: Text(
                            textItem,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Constants.extraColor300,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (isToday)
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "¡Hoy! - ${DateFormat('HH:mm').format(DateTime.parse(widget.appointment.start!).toLocal())}",
                              style: const TextStyle(
                                color: Constants.primaryColor600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      if (daysDifference > 0)
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "En $daysDifference ${daysDifference > 1 ? 'días' : 'dia'} - ${DateFormat('HH:mm').format(DateTime.parse(widget.appointment.start!).toLocal())} hs",
                              style: const TextStyle(
                                color: Constants.otherColor200,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
      ],
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
        Icons.more_vert, color: Colors.grey,
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
                  padding: EdgeInsets.only(left: 8.0,right: 2.0),
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
