part of 'register_patient_bloc.dart';

@immutable
abstract class PatientRegisterState {}

class PatientRegisterInitial extends PatientRegisterState {}

class Loading extends PatientRegisterState {}

class Failed extends PatientRegisterState {
  final response;
  Failed({required this.response});
}

class NavigateNextScreen extends PatientRegisterState {
  final String routeName;
  NavigateNextScreen({required this.routeName});
}

class NavigateNextAndDeleteUntilScreen extends PatientRegisterState {
  final String routeName;
  final String untilName;
  NavigateNextAndDeleteUntilScreen({required this.routeName, required this.untilName});
}

class Success extends PatientRegisterState {}

class SuccessPhotoUploaded extends PatientRegisterState {
  final UrlUploadType actualPhotoStage;
  SuccessPhotoUploaded({required this.actualPhotoStage});
}