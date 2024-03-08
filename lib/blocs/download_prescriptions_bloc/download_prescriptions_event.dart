part of 'download_prescriptions_bloc.dart';

@immutable
abstract class DownloadPrescriptionsEvent extends DownloadEvent {
  DownloadPrescriptionsEvent({
    required super.context,
  });
}

class DownloadPrescriptions extends DownloadPrescriptionsEvent {
  final List<String?> listOfIds;
  DownloadPrescriptions({
    required this.listOfIds,
    required super.context,
  });
}

