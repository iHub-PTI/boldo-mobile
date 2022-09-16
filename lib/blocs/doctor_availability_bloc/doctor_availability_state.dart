part of 'doctor_availability_bloc.dart';

@immutable
abstract class DoctorAvailabilityState{}

class DoctorAvailabilityInitial extends DoctorAvailabilityState {}

class DoctorNextAvailabilityLoaded extends DoctorAvailabilityState {
  final List<NextAvailability>? nextAvailability;
  DoctorNextAvailabilityLoaded({this.nextAvailability});
}

class Loading extends DoctorAvailabilityState {}

class Failed extends DoctorAvailabilityState {
  final response;
  Failed({required this.response});
}

class Success extends DoctorAvailabilityState {}

class RedirectNextScreen extends DoctorAvailabilityState {}

class RedirectToHome extends DoctorAvailabilityState {}

class RedirectBackScreen extends DoctorAvailabilityState {}