part of 'download_studies_orders_bloc.dart';

@immutable
abstract class DownloadStudiesOrdersState extends DownloadState {}

class DownloadStudiesOrdersInitial extends DownloadStudiesOrdersState {}

class Loading extends DownloadStudiesOrdersState {}

class Failed extends DownloadStudiesOrdersState {
  final String msg;

  Failed({required this.msg});
}

class Success extends DownloadStudiesOrdersState {
  final Uint8List file;
  Success({required this.file});
}

class FilesObtained extends DownloadStudiesOrdersState {
  final List<File> files;
  FilesObtained({required this.files});
}

