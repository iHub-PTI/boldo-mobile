part of 'passportBloc.dart';

@immutable
abstract class PassportEvent {}

class GetUserDiseaseList extends PassportEvent {}

class GetUserDiseaseListSync extends PassportEvent {}

class GetUserVaccinationPdfPressed extends PassportEvent {
  bool pdfFromHome;
  GetUserVaccinationPdfPressed({required this.pdfFromHome});
}
