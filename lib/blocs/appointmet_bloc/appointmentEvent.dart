part of 'appointmentBloc.dart';

@immutable
abstract class AppointmentEvent {}

class LinkFamily extends AppointmentEvent {}

class UnlinkDependent extends AppointmentEvent {
  final String id;
  UnlinkDependent({required this.id});
}

class GetPastAppointmentList extends AppointmentEvent {
  final String date;
  GetPastAppointmentList({required this.date});
}

class GetPastAppointmentBetweenDatesList extends AppointmentEvent {
}
