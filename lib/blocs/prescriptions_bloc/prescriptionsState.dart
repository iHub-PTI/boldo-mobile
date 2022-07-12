part of 'prescriptionsBloc.dart';

@immutable
abstract class PrescriptionsState{}

class PrescriptionBlocInitial extends PrescriptionsState {}

class Loading extends PrescriptionsState {}

class Failed extends PrescriptionsState {
  final response;
  Failed({required this.response});
}

class AppointmentLoadedState extends PrescriptionsState {
  final List<Appointment> appointments;
  AppointmentLoadedState({required this.appointments});
}

class AppointmentWithPrescriptionsLoadedState extends PrescriptionsState {
  final List<Appointment> appointments;
  AppointmentWithPrescriptionsLoadedState({required this.appointments});
}

class RedirectNextScreen extends PrescriptionsState {}

class Success extends PrescriptionsState {}
