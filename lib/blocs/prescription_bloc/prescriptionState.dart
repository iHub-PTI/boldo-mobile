part of 'prescriptionBloc.dart';

@immutable
abstract class PrescriptionState{}

class PrescriptionBlocInitial extends PrescriptionState {}

class LoadingPrescription extends PrescriptionState {}

class FailedLoadPrescription extends PrescriptionState {
  final response;
  FailedLoadPrescription({required this.response});
}

class PrescriptionLoaded extends PrescriptionState {
  final Encounter encounter;
  PrescriptionLoaded({required this.encounter});
}
