part of 'download_studies_orders_bloc.dart';

@immutable
abstract class DownloadStudiesOrdersEvent extends DownloadEvent {
  DownloadStudiesOrdersEvent({
    required super.context,
  });
}

class DownloadStudiesOrders extends DownloadStudiesOrdersEvent {
  final List<String?> listOfIds;
  DownloadStudiesOrders({
    required this.listOfIds,
    required super.context,
  });
}

