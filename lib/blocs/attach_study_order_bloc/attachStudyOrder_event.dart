part of 'attachStudyOrder_bloc.dart';

@immutable
abstract class AttachStudyOrderEvent {}

class SendStudyToServer extends AttachStudyOrderEvent {
  final DiagnosticReport diagnosticReport;
  final List<File> files;
  SendStudyToServer({required this.diagnosticReport, required this.files});
}
