part of 'futureAppointments_bloc.dart';

@immutable
abstract class FutureAppointmentsEvent {}

class GetAppointmentsHome extends FutureAppointmentsEvent {}

class DeleteAppointmentHome extends FutureAppointmentsEvent {
  final String? id;
  DeleteAppointmentHome({required this.id});
}
