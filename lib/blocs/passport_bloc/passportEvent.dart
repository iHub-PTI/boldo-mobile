part of 'passportBloc.dart';

@immutable
abstract class PassportEvent {}

class GetUserDiseaseList extends PassportEvent {}

class GetUserDiseaseListSync extends PassportEvent {}
