part of 'prescriptionBloc.dart';

@immutable
abstract class PrescriptionState{}

class PrescriptionBlocInitial extends PrescriptionState {}

class Loading extends PrescriptionState {}

class Failed extends PrescriptionState {
  final response;
  Failed({required this.response});
}

class AppointmentLoadedState extends PrescriptionState {
  final List<Appointment> appointments;
  AppointmentLoadedState({required this.appointments});
}

class AppointmentWithPrescriptionsLoadedState extends PrescriptionState {
  final List<Appointment> appointments;
  AppointmentWithPrescriptionsLoadedState({required this.appointments});
}

class RedirectNextScreen extends PrescriptionState {}

class Success extends PrescriptionState {}
