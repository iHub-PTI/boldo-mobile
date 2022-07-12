part of 'prescriptionBloc.dart';

@immutable
abstract class PrescriptionEvent {}

class InitialPrescriptionEvent extends PrescriptionEvent {}

class GetPrescription extends PrescriptionEvent {
  final String id;
  GetPrescription({required this.id});
}
