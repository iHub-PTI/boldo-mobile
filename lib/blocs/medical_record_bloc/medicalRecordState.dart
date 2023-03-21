part of 'medicalRecordBloc.dart';

@immutable
abstract class MedicalRecordState {}

class MedicalRecordInitial extends MedicalRecordState {}

class Loading extends MedicalRecordState {}

class Failed extends MedicalRecordState {
  final response;
  Failed({required this.response});
}

class MedicalRecordLoadedState extends MedicalRecordState {
  final MedicalRecord medicalRecord;
  MedicalRecordLoadedState({required this.medicalRecord});
}

class Success extends MedicalRecordState {}
