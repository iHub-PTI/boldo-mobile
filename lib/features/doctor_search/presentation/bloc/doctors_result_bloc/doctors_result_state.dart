part of 'doctors_result_bloc.dart';

@immutable
abstract class DoctorsResultState {}

class DoctorsResultInitial extends DoctorsResultState {}

class DoctorsResultLoaded extends DoctorsResultState {
  DoctorsResultLoaded({required this.doctors});
  final PagList<Doctor> doctors;
}

class MoreDoctorsResultLoaded extends DoctorsResultState {
  MoreDoctorsResultLoaded({required this.doctors});
  final PagList<Doctor> doctors;
}

class LoadingResults extends DoctorsResultState {}

class FailedResult extends DoctorsResultState {
  FailedResult({required this.response});
  final String response;
}
