part of 'register_patient_bloc.dart';

@immutable
abstract class PatientRegisterEvent {}

class SendPatientPreliminaryProfilePressed extends PatientRegisterEvent {
  final BuildContext context;
  SendPatientPreliminaryProfilePressed({required this.context});
}

class ValidatePatientPhonePressed extends PatientRegisterEvent {
  final code;
  final BuildContext context;
  ValidatePatientPhonePressed({this.code, required this.context});
}

enum UrlUploadType { frontal, back, selfie }

class UploadPhoto extends PatientRegisterEvent {
  final UrlUploadType urlUploadType;
  final XFile? image;
  UploadPhoto({required this.urlUploadType, required this.image});
}