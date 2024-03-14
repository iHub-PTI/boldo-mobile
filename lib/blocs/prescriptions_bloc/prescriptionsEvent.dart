part of 'prescriptionsBloc.dart';

@immutable
abstract class PrescriptionsEvent {}

class GetPastEncounterWithPrescriptionsList extends PrescriptionsEvent {
  final PrescriptionFilter? prescriptionFilter;
  GetPastEncounterWithPrescriptionsList({
    this.prescriptionFilter,
  });
}
