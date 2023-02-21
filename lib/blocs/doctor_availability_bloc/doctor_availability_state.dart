part of 'doctor_availability_bloc.dart';

@immutable
abstract class DoctorAvailabilityState{}

class DoctorAvailabilityInitial extends DoctorAvailabilityState {}

class Loading extends DoctorAvailabilityState {}

class Failed extends DoctorAvailabilityState {
  final response;
  Failed({required this.response});
}

class Success extends DoctorAvailabilityState {}

class AvailabilitiesObtained extends DoctorAvailabilityState {
  final List<OrganizationWithAvailabilities> availabilities;
  AvailabilitiesObtained({required this.availabilities});
}