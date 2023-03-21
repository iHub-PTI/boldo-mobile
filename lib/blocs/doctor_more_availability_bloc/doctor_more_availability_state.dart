part of 'doctor_more_availability_bloc.dart';

@immutable
abstract class DoctorMoreAvailabilityState{}

class DoctorAvailabilityInitial extends DoctorMoreAvailabilityState {}

class Loading extends DoctorMoreAvailabilityState {}

class Failed extends DoctorMoreAvailabilityState {
  final response;
  Failed({required this.response});
}

class Success extends DoctorMoreAvailabilityState {}

class AvailabilitiesObtained extends DoctorMoreAvailabilityState {
  final List<OrganizationWithAvailabilities> availabilities;
  AvailabilitiesObtained({required this.availabilities});
}