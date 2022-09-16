part of 'dependent_family_bloc.dart';

@immutable
abstract class FamilyEvent {}

class LinkFamily extends FamilyEvent {}

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
