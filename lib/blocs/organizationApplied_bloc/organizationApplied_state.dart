part of 'organizationApplied_bloc.dart';

@immutable
abstract class OrganizationAppliedBlocState{}

class OrganizationInitialState extends OrganizationAppliedBlocState {}

class Loading extends OrganizationAppliedBlocState {}

class Failed extends OrganizationAppliedBlocState {
  final response;
  Failed({required this.response});
}

class Success extends OrganizationAppliedBlocState {}

class OrganizationsObtained extends OrganizationAppliedBlocState {
  final List<Organization> organizationsList;
  OrganizationsObtained({required this.organizationsList});
}

class PostulationRemoved extends OrganizationAppliedBlocState {
  final String id;
  PostulationRemoved({required this.id});
}

class AllOrganizationsObtained extends OrganizationAppliedBlocState {
  final List<Organization> organizationsList;
  AllOrganizationsObtained({required this.organizationsList});
}