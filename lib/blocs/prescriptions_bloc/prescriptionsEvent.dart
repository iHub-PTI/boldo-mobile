part of 'prescriptionsBloc.dart';

@immutable
abstract class PrescriptionsEvent {}

class LinkFamily extends PrescriptionsEvent {}

class UnlinkDependent extends PrescriptionsEvent {
  final String id;
  UnlinkDependent({required this.id});
}

class GetPastAppointmentList extends PrescriptionsEvent {
  final String date;
  GetPastAppointmentList({required this.date});
}

class GetPastAppointmentWithPrescriptionsList extends PrescriptionsEvent {}
