part of 'appointmentsBloc.dart';

@immutable
abstract class AppointmentsEvent {}

class GetPastAppointmentsList extends AppointmentsEvent {
  final String date;
  GetPastAppointmentsList({required this.date});
}

class GetPastAppointmentsBetweenDatesList extends AppointmentsEvent {
}

class GetAppointmentById extends AppointmentsEvent{
  final String id;
  GetAppointmentById({required this.id});
}
