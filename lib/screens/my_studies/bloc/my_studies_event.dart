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

class GetUserPdfFromUrl extends MyStudiesEvent {
  final url;
  GetUserPdfFromUrl({this.url});
}

class DeleteFiles extends MyStudiesEvent {}

class RemoveFile extends MyStudiesEvent {
  final File file;
  RemoveFile({required this.file});
}

class AddFile extends MyStudiesEvent {
  final File file;
  AddFile({required this.file});
}

class AddFiles extends MyStudiesEvent {
  final List<File> files;
  AddFiles({required this.files});
}

class GetFiles extends MyStudiesEvent {}

class GetServiceRequests extends MyStudiesEvent {
  final String serviceRequestId;
  GetServiceRequests({required this.serviceRequestId});
}
