part of 'lastAppointmentBloc.dart';

@immutable
abstract class LastAppointmentState{}

class LastAppointmentInitial extends LastAppointmentState{}

class Loading extends LastAppointmentState {}

class Failed extends LastAppointmentState {
  final response;
  Failed({required this.response});
}

class LastAppointmentLoadedState extends LastAppointmentState {
  final Appointment? appointment;
  LastAppointmentLoadedState({required this.appointment});
}

