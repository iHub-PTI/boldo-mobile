part of 'my_studies_bloc.dart';

@immutable
abstract class MyStudiesEvent {}

class GetPatientStudiesFromServer extends MyStudiesEvent {}

class GetPatientStudyFromServer extends MyStudiesEvent {
  final String id;
  GetPatientStudyFromServer({required this.id});
}

class GetUserPdfFromUrl extends MyStudiesEvent {
  final url;
  GetUserPdfFromUrl({this.url});
}


class GetServiceRequests extends MyStudiesEvent {
  final String serviceRequestId;
  GetServiceRequests({required this.serviceRequestId});
}
