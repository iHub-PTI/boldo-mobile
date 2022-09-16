part of 'medicalRecordBloc.dart';

@immutable
abstract class MedicalRecordEvent {}

class GetMedicalRecord extends MedicalRecordEvent {
  final String appointmentId;
  GetMedicalRecord({required this.appointmentId});
}

class GetMedicalRecordById extends MedicalRecordEvent {
  final String id;
  GetMedicalRecordById({required this.id});
}

class GetStudiesOrderById extends MedicalRecordEvent {
  final String encounterId;
  GetStudiesOrderById({required this.encounterId});
}

class InitialEvent extends MedicalRecordEvent {}
