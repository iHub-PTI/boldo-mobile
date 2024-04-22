part of 'attach_study_order_bloc.dart';

/// Event for uploading a [DiagnosticReport]
@immutable
abstract class AttachStudyOrderEvent {}

/// Event to upload a [DiagnosticReport]
class SendStudyToServer extends AttachStudyOrderEvent {
  /// Event to upload a [DiagnosticReport]
  SendStudyToServer({required this.diagnosticReport, required this.files});

  /// The [DiagnosticReport] that will be upload
  final DiagnosticReport diagnosticReport;

  /// Files that will be upload and attached
  final List<File> files;
}

/// Event to get a [ServiceRequest]
class GetStudyFromServer extends AttachStudyOrderEvent {
  /// Event to get a [ServiceRequest]
  GetStudyFromServer({
    required this.serviceRequestId,
  });

  /// id of the [ServiceRequest]
  final String serviceRequestId;
}
