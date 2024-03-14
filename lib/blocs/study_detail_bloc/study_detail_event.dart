part of 'study_detail_bloc.dart';

@immutable
abstract class StudyDetailEvent {}

class GetPatientStudiesFromServer extends StudyDetailEvent {}

class GetPatientStudyFromServer extends StudyDetailEvent {
  final String id;
  GetPatientStudyFromServer({required this.id});
}

class SendStudyToServer extends StudyDetailEvent {
  final List<File> files;
  final DiagnosticReport diagnosticReport;
  SendStudyToServer({required this.diagnosticReport, required this.files});
}

class GetUserPdfFromUrl extends StudyDetailEvent {
  final url;
  GetUserPdfFromUrl({this.url});
}
