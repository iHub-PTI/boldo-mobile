part of 'lastAppointmentBloc.dart';

@immutable
abstract class LastAppointmentEvent {}

class GetLastAppointment extends LastAppointmentEvent {
  final Doctor doctor;
  GetLastAppointment({required this.doctor});
}

