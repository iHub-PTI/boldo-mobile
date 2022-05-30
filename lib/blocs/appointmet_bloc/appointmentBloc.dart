
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';


part 'appointmentEvent.dart';
part 'appointmentState.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final UserRepository _patientRepository = UserRepository();
  AppointmentBloc() : super(AppointmentInitial()) {
    on<AppointmentEvent>((event, emit) async {
      if(event is GetPastAppointmentList){
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getPastAppointments(event.date)!)
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
          late List<Appointment> appointments;
          _post.foldRight(
              Appointment, (a, previous) => appointments = a);
          emit(AppointmentLoadedState(appointments: appointments));
          emit(Success());
        }
      }
    }

    );
  }
}
