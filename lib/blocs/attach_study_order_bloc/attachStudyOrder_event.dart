part of 'attachStudyOrder_bloc.dart';

@immutable
abstract class AttachStudyOrderEvent {}

class SendStudyToServer extends AttachStudyOrderEvent {
  final DiagnosticReport diagnosticReport;
  final List<File> files;
  SendStudyToServer({required this.diagnosticReport, required this.files});
}

class GetStudyFromServer extends AttachStudyOrderEvent {
  final String serviceRequestId;
  GetStudyFromServer({required this.serviceRequestId,});
}