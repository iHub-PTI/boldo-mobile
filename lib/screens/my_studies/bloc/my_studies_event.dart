part of 'my_studies_bloc.dart';

@immutable
abstract class MyStudiesEvent {}

class GetPatientStudiesFromServer extends MyStudiesEvent {}

class GetPatientStudyFromServer extends MyStudiesEvent {
  final String id;
  GetPatientStudyFromServer({required this.id});
}

class SendStudyToServer extends MyStudiesEvent {
  final List<File> files;
  final DiagnosticReport diagnosticReport;
  SendStudyToServer({required this.diagnosticReport, required this.files});
}