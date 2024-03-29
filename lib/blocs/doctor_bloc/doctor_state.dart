part of 'doctor_bloc.dart';

@immutable
abstract class DoctorState{}

class DoctorInitial extends DoctorState {}


class Loading extends DoctorState {}

class Failed extends DoctorState {
  final response;
  Failed({required this.response});
}

class Success extends DoctorState {}

class AvailabilitiesObtained extends DoctorState {
  final List<OrganizationWithAvailabilities> availabilities;
  AvailabilitiesObtained({required this.availabilities});
}
