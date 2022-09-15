part of 'studyOrder_bloc.dart';

@immutable
abstract class StudyOrderState {}

class StudiesOrderInitial extends StudyOrderState {}

class LoadingOrders extends StudyOrderState {}

class FailedLoadedOrders extends StudyOrderState {
  final response;
  FailedLoadedOrders({required this.response});
}

class StudiesLoaded extends StudyOrderState {
  final List<StudyOrder> studiesOrder;
  StudiesLoaded({required this.studiesOrder});
}

class StudyOrderLoaded extends StudyOrderState {
  final StudyOrder studyOrder;
  StudyOrderLoaded({required this.studyOrder});
}

// appointment loaded succefuly
class AppointmentLoaded extends StudyOrderState {
  final Appointment appointment;
  AppointmentLoaded({required this.appointment});
}

class FailedLoadAppointment extends StudyOrderState {
  final response;
  FailedLoadAppointment({required this.response});
}
