part of 'appointmentBloc.dart';

@immutable
abstract class AppointmentEvent {}

class LinkFamily extends AppointmentEvent {}

class UnlinkDependent extends AppointmentEvent {
  final String id;
  UnlinkDependent({required this.id});
}

class GetPastAppointmentList extends AppointmentEvent {}
