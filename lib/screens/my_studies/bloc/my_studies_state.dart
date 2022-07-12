part of 'my_studies_bloc.dart';

@immutable
abstract class MyStudiesState {}

class MyStudiesInitial extends MyStudiesState {}

class DiagnosticLoaded extends MyStudiesState {
  final List<DiagnosticReport> studiesList;

  DiagnosticLoaded({required this.studiesList});
}

class DiagnosticStudyLoaded extends MyStudiesState {
  final DiagnosticReport study;

  DiagnosticStudyLoaded({required this.study});
}

class Loading extends MyStudiesState {}

class Failed extends MyStudiesState {
  final String msg;

  Failed({required this.msg});
}

class FailedUpload extends MyStudiesState {
  final String msg;

  FailedUpload({required this.msg});
}

class Uploading extends MyStudiesState {}

class Uploaded extends MyStudiesState {}

class Success extends MyStudiesState {}
