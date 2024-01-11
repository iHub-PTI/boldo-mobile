part of 'new_study_bloc.dart';

@immutable
abstract class NewStudyEvent {}

class SendStudyToServer extends NewStudyEvent {
  final List<MapEntry<File, Either<Failure, AttachmentUrl?>>> files;
  final DiagnosticReport diagnosticReport;
  SendStudyToServer({required this.diagnosticReport, required this.files});
}
