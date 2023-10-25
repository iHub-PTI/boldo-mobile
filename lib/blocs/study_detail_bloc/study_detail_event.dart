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

class DeleteFiles extends StudyDetailEvent {}

class RemoveFile extends StudyDetailEvent {
  final File file;
  RemoveFile({required this.file});
}

class AddFile extends StudyDetailEvent {
  final File file;
  AddFile({required this.file});
}

class AddFiles extends StudyDetailEvent {
  final List<File> files;
  AddFiles({required this.files});
}

class GetFiles extends StudyDetailEvent {}

class GetServiceRequests extends StudyDetailEvent {
  final String serviceRequestId;
  GetServiceRequests({required this.serviceRequestId});
}
