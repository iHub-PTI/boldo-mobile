part of 'organizationSubscribed_bloc.dart';

@immutable
abstract class OrganizationSubscribedBlocState{}

class OrganizationInitialState extends OrganizationSubscribedBlocState {}

class Loading extends OrganizationSubscribedBlocState {}

class Failed extends OrganizationSubscribedBlocState {
  final response;
  Failed({required this.response});
}

class Success extends OrganizationSubscribedBlocState {}

class OrganizationsSubscribedObtained extends OrganizationSubscribedBlocState {
  final List<Organization> organizationsList;
  OrganizationsSubscribedObtained({required this.organizationsList});
}

class OrganizationRemoved extends OrganizationSubscribedBlocState {
  final String id;
  OrganizationRemoved({required this.id});
}

class AllOrganizationsObtained extends OrganizationSubscribedBlocState {
  final List<Organization> organizationsList;
  AllOrganizationsObtained({required this.organizationsList});
}

class PriorityEstablished extends OrganizationSubscribedBlocState {}