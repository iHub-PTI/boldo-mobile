part of 'doctors_available_bloc.dart';

@immutable
abstract class DoctorsAvailableState {}

class DoctorsAvailableInitial extends DoctorsAvailableState {}

class DoctorsLoaded extends DoctorsAvailableState {
  final PagList<Doctor> doctors;
  DoctorsLoaded({required this.doctors});
}

class MoreDoctorsLoaded extends DoctorsAvailableState {
  final PagList<Doctor> doctors;
  MoreDoctorsLoaded({required this.doctors});
}

class FilterLoaded extends DoctorsAvailableState {
  final PagList<Doctor> doctors;
  FilterLoaded({required this.doctors});
}

class FilterLoadedInDoctorList extends DoctorsAvailableState {
  final PagList<Doctor> doctors;
  FilterLoadedInDoctorList({required this.doctors});
}

class SpecializationsLoaded extends DoctorsAvailableState {
  List<Specializations> specializations;
  SpecializationsLoaded({required this.specializations});
}

class Loading extends DoctorsAvailableState {}

class FilterLoading extends DoctorsAvailableState {}

class FilterLoadingInDoctorList extends DoctorsAvailableState {}

class Success extends DoctorsAvailableState {}

class FilterSucces extends DoctorsAvailableState {}

class FilterSuccesInDoctorList extends DoctorsAvailableState {}

class Failed extends DoctorsAvailableState {
  final response;
  Failed({required this.response});
}

class FilterFailed extends DoctorsAvailableState {
  final response;
  FilterFailed({required this.response});
}

class FilterFailedInDoctorList extends DoctorsAvailableState {
  final response;
  FilterFailedInDoctorList({required this.response});
}
