import 'package:boldo/blocs/appointment_bloc/appointmentBloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/screens/appointments/medicalRecordScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ShowAppointmentOrigin extends StatelessWidget {

  final String encounterId;

  ShowAppointmentOrigin({Key? key, required this.encounterId}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppointmentBloc>(
      create: (BuildContext context) => AppointmentBloc(),
      child: BlocListener<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if(state is AppointmentLoadedState){
            Appointment appointment = state.appointment;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                  MedicalRecordsScreen(
                    appointment: appointment,
                  ),
                settings: RouteSettings(name: (MedicalRecordsScreen).toString()),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BlocBuilder<AppointmentBloc, AppointmentState>(
              builder: (context, state) {
                if (state is Loading) {
                  return Container(
                      child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Constants.primaryColor400),
                            backgroundColor: Constants.primaryColor600,
                          )));
                } else {
                  return InkWell(
                    onTap: () async {
                      BlocProvider.of<
                          AppointmentBloc>(
                          context)
                          .add(GetAppointmentByEcounterId(
                        encounterId: encounterId,
                      ));
                    },
                    child: Row(
                      children: [
                        const Text(
                          'ver consulta de origen',
                          style: TextStyle(
                            decoration:
                            TextDecoration
                                .underline,
                            fontFamily:
                            'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: ConstantsV2.darkBlue,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        SvgPicture.asset(
                          'assets/icon/chevron-right.svg',
                          height: 12,
                          color: ConstantsV2.darkBlue,
                        )
                      ],
                    ),
                  );
                }
              }
          ),
        ),
      ),
    );
  }


}