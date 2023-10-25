part of 'study_detail_bloc.dart';

@immutable
abstract class StudyDetailState {}

class StudyDetailInitial extends StudyDetailState {}

class DiagnosticLoaded extends StudyDetailState {
  final List<DiagnosticReport> studiesList;

  DiagnosticLoaded({required this.studiesList});
}

class DiagnosticStudyLoaded extends StudyDetailState {
  final DiagnosticReport study;

  DiagnosticStudyLoaded({required this.study});
}

class Loading extends StudyDetailState {}

class Failed extends StudyDetailState {
  final String msg;

  Failed({required this.msg});
}

class FailedUpload extends StudyDetailState {
  final String msg;

  FailedUpload({required this.msg});
}

class Uploading extends StudyDetailState {}

class Uploaded extends StudyDetailState {}

class Success extends StudyDetailState {}

class FilesObtained extends StudyDetailState {
  final List<File> files;
  FilesObtained({required this.files});
}

class ServiceRequestLoaded extends StudyDetailState {
  final ServiceRequest serviceRequest;
  ServiceRequestLoaded({required this.serviceRequest});
}
