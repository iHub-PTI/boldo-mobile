part of 'homeOrganization_bloc.dart';

@immutable
abstract class HomeOrganizationBlocEvent {}

class SubscribeToAnOrganization extends HomeOrganizationBlocEvent {
  final String id;
  SubscribeToAnOrganization({required this.id});
}

class GetOrganizationById extends HomeOrganizationBlocEvent {
  final String id;
  GetOrganizationById({required this.id});
}

class GetOrganizationsSubscribed extends HomeOrganizationBlocEvent {}

class GetAllOrganizations extends HomeOrganizationBlocEvent {}
