part of 'download_bloc.dart';

@immutable
abstract class DownloadState {}

class DownloadInitial extends DownloadState {}

abstract class Loading extends DownloadState {}

abstract class Failed extends DownloadState {
  final String msg;

  Failed({required this.msg});
}

abstract class Success extends DownloadState {
  final Uint8List file;
  Success({required this.file});
}

