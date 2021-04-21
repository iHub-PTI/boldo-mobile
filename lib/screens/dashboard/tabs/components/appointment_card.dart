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

//FIXME: All the cancel appointment flow is control by appointment.reason != null.
//when user cancel, the appointment history come with a reason why this was cancelled
//I dont sure if the smooth way to do, but for now was the only params that I can use to managment this.
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
            height: 105,
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
                  Text(
                    "${getDoctorPrefix(widget.appointment.doctor.gender)}${widget.appointment.doctor.familyName}",
                    style: const TextStyle(
                      color: Constants.extraColor400,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                    height: 5,
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
            final response = await alertForCancelAppointment(context: context);
            if (response == true) {
              try {
                //Fixme: The cancel Appointment only will work with VPN ative
                final response = await dioHealthCore.post(
                  "/profile/patient/appointments/cancel/${widget.appointment.id}",
                );

                if (response.data["reason"] != null)
                  widget.appointment.reason = "Cancelled";
                setState(() {});
              } on DioError catch (ex) {
                print(ex);
              }
            }
          },
          color: Constants.primaryColor500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Text(
            'Cancelar Cita',
            style: TextStyle(color: Constants.extraColor100, fontSize: 10),
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

  Future<bool> alertForCancelAppointment(
      {@required BuildContext context}) async {
    return showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (
          BuildContext context,
        ) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Center(
                child: Card(
                  elevation: 11,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: 256,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "¡Cancelar Cita!",
                          style: TextStyle(
                              color: Constants.extraColor400,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "¿Seguro que quieres cancelar tu cita?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Constants.extraColor300,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(
                                  color: Constants.primaryColor600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop(true);
                                return true;
                              },
                              child: const Text("Continuar"),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
