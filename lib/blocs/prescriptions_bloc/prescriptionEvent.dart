part of 'prescriptionBloc.dart';

@immutable
abstract class PrescriptionEvent {}

class LinkFamily extends PrescriptionEvent {}

class UnlinkDependent extends PrescriptionEvent {
  final String id;
  UnlinkDependent({required this.id});
}

class GetPastAppointmentList extends PrescriptionEvent {
  final String date;
  GetPastAppointmentList({required this.date});
}

class GetPastAppointmentWithPrescriptionsList extends PrescriptionEvent {
  final String date;
  GetPastAppointmentWithPrescriptionsList({required this.date});
}
