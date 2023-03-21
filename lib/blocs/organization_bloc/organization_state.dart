part of 'organization_bloc.dart';

@immutable
abstract class OrganizationBlocState {}

class OrganizationInitialState extends OrganizationBlocState {}

class Loading extends OrganizationBlocState {}

class Failed extends OrganizationBlocState {
  final response;
  Failed({required this.response});
}

class Success extends OrganizationBlocState {}

class SuccessSubscribed extends OrganizationBlocState {}

class OrganizationsObtained extends OrganizationBlocState {
  final List<Organization> organizationsList;
  OrganizationsObtained({required this.organizationsList});
}

class AllOrganizationsObtained extends OrganizationBlocState {
  final List<Organization> organizationsList;
  AllOrganizationsObtained({required this.organizationsList});
}