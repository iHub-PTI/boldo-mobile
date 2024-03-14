part of 'download_bloc.dart';

@immutable
abstract class DownloadEvent {
  final BuildContext context;
  DownloadEvent({required this.context});
}

abstract class Download extends DownloadEvent {
  final List<String?> listOfIds;
  Download({required this.listOfIds, required super.context});
}

