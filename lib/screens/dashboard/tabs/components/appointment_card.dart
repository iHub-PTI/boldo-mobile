import 'package:boldo/network/http.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';

class AppointmentCard extends StatefulWidget {
  final Appointment appointment;

  const AppointmentCard({
    Key key,
    @required this.appointment,
  }) : super(key: key);

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    int daysDifference = DateTime.parse(widget.appointment.start)
        .toLocal()
        .difference(DateTime.now())
        .inDays;
    bool isToday = daysDifference == 0 &&
        !["closed", "locked"].contains(widget.appointment.status);

    return Card(
      elevation: 1.4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
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
                  : Constants.tertiaryColor200,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM').format(
                      DateTime.parse(widget.appointment.start).toLocal()),
                  style: TextStyle(
                    color: isToday
                        ? Constants.extraColor100
                        : Constants.primaryColor500,
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateFormat('dd').format(
                      DateTime.parse(widget.appointment.start).toLocal()),
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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Positioned(
                    left: 0.0,
                    child: Text(
                      "${getDoctorPrefix(widget.appointment.doctor.gender)}${widget.appointment.doctor.familyName}",
                      style: const TextStyle(
                        color: Constants.extraColor400,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  if (widget.appointment.doctor.specializations != null &&
                      widget.appointment.doctor.specializations.isNotEmpty)
                    Row(
                      children: [
                        for (int i = 0;
                            i <
                                widget
                                    .appointment.doctor.specializations.length;
                            i++)
                          Row(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: i == 0 ? 0 : 3.0),
                                child: Text(
                                  "${widget.appointment.doctor.specializations[i].description}${widget.appointment.doctor.specializations.length > 1 && i == 0 ? "," : ""}",
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
                          "¡Hoy! - ${DateFormat('HH:mm').format(DateTime.parse(widget.appointment.start).toLocal())}",
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
                          "En $daysDifference días - ${DateFormat('HH:mm').format(DateTime.parse(widget.appointment.start).toLocal())}",
                          style: const TextStyle(
                            color: Constants.otherColor200,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  showAppoinmentStatus(),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget showAppoinmentStatus() {
    if (widget.appointment.status == "locked" ||
        widget.appointment.status == "closed") {
      return Container();
    } else if (widget.appointment.reason == null &&
        widget.appointment.status == "upcoming") {
      return Container(
        width: 99,
        height: 30,
        child: FlatButton(
          onPressed: () async {
            try {
              final response = await dioKeyCloack.post(
                "/profile/patient/appointments/cancel/${widget.appointment.id}",
              );
              print(response);
              if (response.data["reason"] != null)
                widget.appointment.reason = "Cancelled";
              setState(() {});
            } on DioError catch (ex) {
              print(ex);
            }
          },
          color: const Color.fromRGBO(246, 174, 15, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Text(
            'Cancelar Cita',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      );
    } else
      return Container(
        child: Text('Cita Cancelada',
            style:
                TextStyle(color: Colors.red[300], fontWeight: FontWeight.bold)),
      );
  }
}
