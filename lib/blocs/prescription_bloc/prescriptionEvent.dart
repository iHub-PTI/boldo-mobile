part of 'prescriptionBloc.dart';

@immutable
abstract class PrescriptionEvent {}

class InitialEvent extends PrescriptionEvent {}

class GetPrescription extends PrescriptionEvent {
  final String id;
  GetPrescription({required this.id});
}
