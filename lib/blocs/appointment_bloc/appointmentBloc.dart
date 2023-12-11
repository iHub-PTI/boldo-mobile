
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/network/appointment_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



part 'appointmentEvent.dart';
part 'appointmentState.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  static List<MapEntry<AppointmentStatus, AppointmentStatus>> statusChangeValidatorList = [
    const MapEntry(AppointmentStatus.Upcoming, AppointmentStatus.Upcoming),
    const MapEntry(AppointmentStatus.Upcoming, AppointmentStatus.Open),
    const MapEntry(AppointmentStatus.Upcoming, AppointmentStatus.Cancelled),
    const MapEntry(AppointmentStatus.Open, AppointmentStatus.Open),
    const MapEntry(AppointmentStatus.Open, AppointmentStatus.Cancelled),
    const MapEntry(AppointmentStatus.Open, AppointmentStatus.Closed),
    const MapEntry(AppointmentStatus.Open, AppointmentStatus.Locked),
    const MapEntry(AppointmentStatus.Closed, AppointmentStatus.Locked),
    const MapEntry(AppointmentStatus.Closed, AppointmentStatus.Open),
    const MapEntry(AppointmentStatus.Closed, AppointmentStatus.Closed),
    const MapEntry(AppointmentStatus.Locked, AppointmentStatus.Locked),
  ];

  AppointmentBloc() : super(AppointmentInitial()) {
    on<AppointmentEvent>((event, emit) async {
      if(event is GetAppointmentByEcounterId){
        emit(Loading());
        var _post;
        await Task(() => AppointmentRepository.getAppointmentByEncounterId(encounterId: event.encounterId)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
        } else {
          late Appointment appointment;
          _post.foldRight(Appointment, (a, previous) => appointment = a);

          emit(AppointmentLoadedState(appointment: appointment));
        }
      }
    }

    );
  }
}

class InvalidAppointmentStatusChange implements Exception{


  final String message;


  const InvalidAppointmentStatusChange([
    this.message = "Invalid status change",
  ]);

  @override
  String toString(){
    return message;
  }
}