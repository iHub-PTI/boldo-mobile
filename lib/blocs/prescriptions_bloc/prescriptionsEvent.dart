part of 'prescriptionsBloc.dart';

@immutable
abstract class PrescriptionsEvent {}

class GetPastAppointmentWithPrescriptionsList extends PrescriptionsEvent {}
