part of 'organizationSubscribed_bloc.dart';

@immutable
abstract class OrganizationSubscribedBlocEvent {}


class GetOrganizationsSubscribed extends OrganizationSubscribedBlocEvent {}

class RemoveOrganization extends OrganizationSubscribedBlocEvent {
  final Organization organization;
  RemoveOrganization({required this.organization});
}

class ReorderByPriority extends OrganizationSubscribedBlocEvent {
  final List<Organization> organizations;
  ReorderByPriority({required this.organizations});
}