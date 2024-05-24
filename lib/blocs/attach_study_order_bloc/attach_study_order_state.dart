part of 'attach_study_order_bloc.dart';

/// Status for upload study order
@immutable
abstract class AttachStudyOrderState {}

/// Initial state for Upload a studyOrder
class StudiesOrderInitial extends AttachStudyOrderState {}

/// Uploading status
class UploadingStudy extends AttachStudyOrderState {}

/// Loading status
class LoadingStudies extends AttachStudyOrderState {}

/// Failed status on upload with his respective error message
class FailedUploadFiles extends AttachStudyOrderState {
  /// Failed status with his respective error message
  FailedUploadFiles({required this.response});

  /// Error message
  final String response;
}

/// Failed status on get study with his respective error message
class FailedLoadedStudies extends AttachStudyOrderState {
  /// Failed status on get study with his respective error message
  FailedLoadedStudies({required this.response});

  /// Error message
  final String response;
}

/// Success status for upload
class SendSuccess extends AttachStudyOrderState {}

/// Success status for get study
class StudyObtained extends AttachStudyOrderState {
  /// Success status for get study
  StudyObtained({
    required this.serviceRequest,
  });

  /// Study
  final ServiceRequest? serviceRequest;
}
