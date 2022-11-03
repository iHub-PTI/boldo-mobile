part of 'dependent_family_bloc.dart';

@immutable
abstract class FamilyEvent {}

class LinkFamily extends FamilyEvent {}

class LinkWithoutCi extends FamilyEvent {
  final String givenName;
  final String familyName;
  final String birthDate;
  final String gender;
  final String identifier;
  final String relationShipCode;
  LinkWithoutCi(
      {required this.givenName,
      required this.familyName,
      required this.birthDate,
      required this.gender,
      required this.identifier,
      required this.relationShipCode});
}

class UnlinkDependent extends FamilyEvent {
  final String id;
  UnlinkDependent({required this.id});
}

class GetFamilyList extends FamilyEvent {}

class GetManagersList extends FamilyEvent {}

class UnlinkCaretaker extends FamilyEvent {
  final String id;
  UnlinkCaretaker({required this.id});
}
