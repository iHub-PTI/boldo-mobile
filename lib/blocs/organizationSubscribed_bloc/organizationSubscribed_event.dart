part of 'organizationSubscribed_bloc.dart';

@immutable
abstract class OrganizationSubscribedBlocEvent {}


class GetOrganizationsSubscribed extends OrganizationSubscribedBlocEvent {
  final Patient patientSelected;
  GetOrganizationsSubscribed({required this.patientSelected});
}

class RemoveOrganization extends OrganizationSubscribedBlocEvent {
  final Patient patientSelected;
  final Organization organization;
  RemoveOrganization({required this.organization, required this.patientSelected});
}

class ReorderByPriority extends OrganizationSubscribedBlocEvent {
  final Patient patientSelected;
  final List<Organization> organizations;
  ReorderByPriority({required this.organizations, required this.patientSelected});
}