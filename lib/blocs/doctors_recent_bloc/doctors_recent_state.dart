part of 'doctors_recent_bloc.dart';

@immutable
abstract class RecentDoctorsState{}

class DoctorAvailabilityInitial extends RecentDoctorsState {}

class LoadingRecentDoctors extends RecentDoctorsState {}

class FailedRecentDoctors extends RecentDoctorsState {
  final response;
  FailedRecentDoctors({required this.response});
}

class SuccessRecentDoctors extends RecentDoctorsState {}

class RecentDoctorsLoaded extends RecentDoctorsState {
  final List<Doctor> doctors;
  RecentDoctorsLoaded({required this.doctors});
}