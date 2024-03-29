part of 'dependent_family_bloc.dart';

@immutable
abstract class FamilyState {}

class FamilyInitial extends FamilyState {}

class Loading extends FamilyState {}

class RelationLoading extends FamilyState {}
class Failed extends FamilyState {
  final response;
  Failed({required this.response});
}

class RelationFailed extends FamilyState {
  final response;
  RelationFailed({required this.response});
}

class RedirectNextScreen extends FamilyState {}

class Success extends FamilyState {}

class DependentEliminated extends FamilyState {}

class CaretakersObtained extends FamilyState {
  final List<Patient> caretakers;
  CaretakersObtained({required this.caretakers});
}

class RelationSuccess extends FamilyState {}