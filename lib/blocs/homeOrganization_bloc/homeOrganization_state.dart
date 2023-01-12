part of 'homeOrganization_bloc.dart';

@immutable
abstract class HomeOrganizationBlocState{}

class HomeOrganizationInitialState extends HomeOrganizationBlocState {}

class HomeOrganizationLoading extends HomeOrganizationBlocState {}

class HomeOrganizationFailed extends HomeOrganizationBlocState {
  final response;
  HomeOrganizationFailed({required this.response});
}

class HomeOrganizationSuccess extends HomeOrganizationBlocState {}

class OrganizationsObtained extends HomeOrganizationBlocState {
  final List<Organization> organizationsList;
  OrganizationsObtained({required this.organizationsList});
}

class AllOrganizationsObtained extends HomeOrganizationBlocState {
  final List<Organization> organizationsList;
  AllOrganizationsObtained({required this.organizationsList});
}