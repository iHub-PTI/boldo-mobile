import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/screens/Call/components/call_ended_popup.dart';
import 'package:boldo/screens/Call/video_call.dart';
import 'package:flutter/material.dart';
import 'package:boldo/utils/helpers.dart';

class WaitingRoomCard extends StatelessWidget {
  final Appointment appointment;
  final Function() getAppointmentsData;
  const WaitingRoomCard(
      {Key? key, required this.appointment, required this.getAppointmentsData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 24),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Sala de espera",
                    style: boldoHeadingTextStyle,
                  ),
                  const SizedBox(height: 3),
                  Text(
                      "La sala de espera de tu consulta con ${getDoctorPrefix(appointment.doctor.gender)}${appointment.doctor.familyName} ya se encuentra habilitada. ",
                      style: boldoSubTextStyle.copyWith(
                        height: 1.2,
                        fontSize: 15,
                      ))
                ]),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xffE5E7EB),
          ),
          Container(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextButton(
                      onPressed: () async {
                        final updateAppointments = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoCall(appointment: appointment),
                          ),
                        );

                        if (updateAppointments != null) {
                          if (updateAppointments["error"] != null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(updateAppointments["error"])));
                          }
                          if (updateAppointments["appointment"] != null) {
                            await callEndedPopup(
                                context: context,
                                appointment: updateAppointments["appointment"]);
                            getAppointmentsData();
                          } else if (updateAppointments["tokenError"] != null) {
                            //reload data
                            getAppointmentsData();
                            // show scnackbar
                            Scaffold.of(context).showSnackBar(const SnackBar(
                                content: Text(
                                    'Algo salió mal, por favor intente de nuevo más tarde')));
                          }
                        }
                      },
                      child: Text(
                        'Ingresar',
                        style: boldoHeadingTextStyle.copyWith(
                            color: Constants.primaryColor500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
