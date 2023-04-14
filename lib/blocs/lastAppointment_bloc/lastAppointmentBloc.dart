
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/appointment_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



part 'lastAppointmentEvent.dart';
part 'lastAppointmentState.dart';

class LastAppointmentBloc extends Bloc<LastAppointmentEvent, LastAppointmentState> {
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  LastAppointmentBloc() : super(LastAppointmentInitial()) {
    on<LastAppointmentEvent>((event, emit) async {
      if(event is GetLastAppointment){
        emit(Loading());
        var _post;
        await Task(() =>
        _appointmentRepository.getLastAppointment(event.doctor)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          late Appointment? appointment;
          _post.foldRight(
              Appointment, (a, previous) => appointment = a);
          emit(LastAppointmentLoadedState(appointment: appointment));
        }
      }
    }

    );
  }
}
