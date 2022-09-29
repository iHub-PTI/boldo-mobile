part of 'doctors_available_bloc.dart';

@immutable
abstract class DoctorsAvailableState {}

class DoctorsAvailableInitial extends DoctorsAvailableState {}

class DoctorsLoaded extends DoctorsAvailableState {
  List<Doctor> doctors;
  DoctorsLoaded({required this.doctors});
}

class Loading extends DoctorsAvailableState {}

class Success extends DoctorsAvailableState {}

class Failed extends DoctorsAvailableState {
  final response;
  Failed({required this.response});
}
