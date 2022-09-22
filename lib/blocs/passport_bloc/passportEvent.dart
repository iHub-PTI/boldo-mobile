part of 'passportBloc.dart';

@immutable
abstract class PassportEvent {}

class GetUserDiseaseList extends PassportEvent {}

class GetUserDiseaseListSync extends PassportEvent {}

class GetUserVaccinationPdfPressed extends PassportEvent {
  final bool pdfFromHome;
  GetUserVaccinationPdfPressed({required this.pdfFromHome});
}

class GetUserQrCode extends PassportEvent{}