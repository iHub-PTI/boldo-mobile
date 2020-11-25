import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({
    Key key,
    @required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int daysDifference = DateTime.parse(appointment.start)
        .toLocal()
        .difference(DateTime.now())
        .inDays;
    // bool isPast =
    //     DateTime.parse(appointment.start).toLocal().isBefore(DateTime.now());
    bool isToday = daysDifference == 0 && appointment.status != "closed";
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
                  DateFormat('MMM').format(DateTime.parse(appointment.start)),
                  style: TextStyle(
                    color: isToday
                        ? Constants.extraColor100
                        : Constants.primaryColor500,
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateFormat('dd').format(DateTime.parse(appointment.start)),
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
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dr. Gregory House",
                style: TextStyle(
                  color: Constants.extraColor400,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                "Clínico General",
                style: TextStyle(
                  color: Constants.extraColor300,
                  fontSize: 14,
                ),
              ),
              if (isToday)
                Column(
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    const Text(
                      "¡Hoy!",
                      style: TextStyle(
                        color: Constants.primaryColor600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              if (daysDifference > 0)
                Column(
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "En $daysDifference días",
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
    );
  }
}
