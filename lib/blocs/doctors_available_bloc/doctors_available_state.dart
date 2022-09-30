part of 'doctors_available_bloc.dart';

@immutable
abstract class DoctorsAvailableState {}

class DoctorsAvailableInitial extends DoctorsAvailableState {}

class DoctorsLoaded extends DoctorsAvailableState {
  List<Doctor> doctors;
  DoctorsLoaded({required this.doctors});
}

class FilterLoaded extends DoctorsAvailableState {
  List<Doctor> doctors;
  FilterLoaded({required this.doctors});
}

class SpecializationsLoaded extends DoctorsAvailableState {
  List<Specializations> specializations;
  SpecializationsLoaded({required this.specializations});
}

class Loading extends DoctorsAvailableState {}

class Success extends DoctorsAvailableState {}

class Failed extends DoctorsAvailableState {
  final response;
  Failed({required this.response});
}
