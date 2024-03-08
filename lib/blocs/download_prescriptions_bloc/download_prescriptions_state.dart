part of 'download_prescriptions_bloc.dart';

@immutable
abstract class DownloadPrescriptionsState extends DownloadState {}

class DownloadPrescriptionsInitial extends DownloadPrescriptionsState {}

class Loading extends DownloadPrescriptionsState {}

class Failed extends DownloadPrescriptionsState {
  final String msg;

  Failed({required this.msg});
}

class Success extends DownloadPrescriptionsState {
  final Uint8List file;
  Success({required this.file});
}

class FilesObtained extends DownloadPrescriptionsState {
  final List<File> files;
  FilesObtained({required this.files});
}

