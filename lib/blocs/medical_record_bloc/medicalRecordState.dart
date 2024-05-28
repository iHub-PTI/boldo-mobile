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
  final Encounter encounter;
  MedicalRecordLoadedState({required this.encounter});
}

class Success extends MedicalRecordState {}
