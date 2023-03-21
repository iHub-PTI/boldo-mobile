part of 'homeAppointments_bloc.dart';

@immutable
abstract class HomeAppointmentsEvent {}

class GetAppointmentsHome extends HomeAppointmentsEvent {}

class DeleteAppointmentHome extends HomeAppointmentsEvent {
  final String? id;
  DeleteAppointmentHome({required this.id});
}
