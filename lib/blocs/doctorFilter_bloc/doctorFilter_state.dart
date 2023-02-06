part of 'doctorFilter_bloc.dart';

@immutable
abstract class DoctorFilterState{}

class DoctorFilterInitial extends DoctorFilterState {}

class LoadingDoctorFilter extends DoctorFilterState {}

class FailedDoctorFilter extends DoctorFilterState {
  final response;
  FailedDoctorFilter({required this.response});
}

class SuccessDoctorFilter extends DoctorFilterState {
  final List<Doctor> doctorList;
  SuccessDoctorFilter({required this.doctorList});
}
