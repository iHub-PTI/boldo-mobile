part of 'appointments_bloc.dart';

/// Event for [AppointmentsBloc]
@immutable
abstract class AppointmentsEvent {}

/// Event to get a list of [Appointment] from an initialDate to
/// the future
class GetPastAppointmentsList extends AppointmentsEvent {
  /// Event to get a list of [Appointment] from an initialDate to
  /// the future
  GetPastAppointmentsList({required this.date});

  /// initial date to get the appointments
  final String date;
}

/// Get a list of [Appointment] bewtenn
class GetPastAppointmentsBetweenDatesList extends AppointmentsEvent {}

class GetAppointmentById extends AppointmentsEvent {
  final String id;
  GetAppointmentById({required this.id});
}
