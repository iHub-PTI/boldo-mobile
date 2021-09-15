import 'package:boldo/screens/details/appointment_details.dart';
import 'package:boldo/screens/details/prescription_details.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isInWaitingRoom;

  const AppointmentCard({
    Key key,
    @required this.appointment,
    @required this.isInWaitingRoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actualDay = DateTime.now();
    final appointmentDay = DateTime.parse(appointment.start);
    int daysDifference = DateTime.parse(appointment.start)
        .toLocal()
        .difference(actualDay)
        .inDays;
    if (actualDay.month == appointmentDay.month) {
      daysDifference = appointmentDay.day - actualDay.day;
    }
    bool isToday = daysDifference == 0 &&
        !["closed", "locked"].contains(appointment.status);

    String textItem = '';
    if (appointment.prescriptions != null) {
      for (int i = 0; i < appointment.prescriptions.length; i++) {
        textItem = textItem +
            "${appointment.prescriptions[i].medicationName}${appointment.prescriptions.length > 1 && i == 0 ? "," : ""}";
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailsScreen(
                      appointment: appointment,
                      isInWaitingRoom: isInWaitingRoom),
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
                      SvgPicture.asset('assets/icon/phone.svg',
                          fit: BoxFit.cover),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMM').format(
                            DateTime.parse(appointment.start).toLocal()),
                        style: TextStyle(
                          color: isToday
                              ? Constants.extraColor100
                              : Constants.primaryColor500,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        DateFormat('dd').format(
                            DateTime.parse(appointment.start).toLocal()),
                        style: TextStyle(
                          color: isToday
                              ? Constants.extraColor100
                              : Constants.primaryColor500,
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
                      "${getDoctorPrefix(appointment.doctor.gender)}${appointment.doctor.familyName}",
                      style: const TextStyle(
                        color: Constants.extraColor400,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    if (appointment.doctor.specializations != null &&
                        appointment.doctor.specializations.isNotEmpty)
                      Row(
                        children: [
                          for (int i = 0;
                              i < appointment.doctor.specializations.length;
                              i++)
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: i == 0 ? 0 : 3.0),
                                  child: Text(
                                    "${appointment.doctor.specializations[i].description}${appointment.doctor.specializations.length > 1 && i == 0 ? "," : ""}",
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
                    if (isToday)
                      Column(
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "¡Hoy! - ${DateFormat('HH:mm').format(DateTime.parse(appointment.start).toLocal())}",
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
                            "En $daysDifference ${daysDifference > 1 ? 'días':'dia'}  - ${DateFormat('HH:mm').format(DateTime.parse(appointment.start).toLocal())}",
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
        if (appointment.prescriptions != null &&
            appointment.prescriptions.isNotEmpty)
          Card(
            elevation: 1.4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrescriptionDetailsScreen(
                      appointment: appointment,
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
                              DateTime.parse(appointment.start).toLocal()),
                          style: const TextStyle(
                            color: Color(0xffDF6D51),
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DateFormat('dd').format(
                              DateTime.parse(appointment.start).toLocal()),
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
                      if (appointment.prescriptions != null &&
                          appointment.prescriptions.isNotEmpty)
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
                              "¡Hoy! - ${DateFormat('HH:mm').format(DateTime.parse(appointment.start).toLocal())}",
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
                              "En $daysDifference ${daysDifference > 1 ? 'días':'dia'} - ${DateFormat('HH:mm').format(DateTime.parse(appointment.start).toLocal())}",
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
