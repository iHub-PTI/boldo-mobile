part of 'new_study_bloc.dart';

@immutable
abstract class NewStudyState {}

class NewStudyInitial extends NewStudyState {}

class Loading extends NewStudyState {}

class FailedUploadFiles extends NewStudyState {
  final List<MapEntry<File, Either<Failure, AttachmentUrl?>>> files;

  FailedUploadFiles({required this.files});
}

class FailedUpload extends NewStudyState {
  final String msg;

  FailedUpload({required this.msg});
}

class Uploading extends NewStudyState {}

class Uploaded extends NewStudyState {}
