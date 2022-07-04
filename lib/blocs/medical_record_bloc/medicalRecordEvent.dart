part of 'medicalRecordBloc.dart';

@immutable
abstract class MedicalRecordEvent {}

class GetMedicalRecord extends MedicalRecordEvent {
  final String appointmentId;
  GetMedicalRecord({required this.appointmentId});
}

class InitialEvent extends MedicalRecordEvent {}
