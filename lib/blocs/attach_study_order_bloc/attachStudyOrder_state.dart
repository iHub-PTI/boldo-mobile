part of 'attachStudyOrder_bloc.dart';

@immutable
abstract class AttachStudyOrderState{}

class StudiesOrderInitial extends AttachStudyOrderState {}

class UploadingStudy extends AttachStudyOrderState {}

class FailedUploadFiles extends AttachStudyOrderState {
  final response;
  FailedUploadFiles({required this.response});
}

class SendSuccess extends AttachStudyOrderState {}

class StudyObtained extends AttachStudyOrderState {
  final ServiceRequest? serviceRequest;
  StudyObtained({required this.serviceRequest,});
}