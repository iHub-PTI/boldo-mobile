part of 'organizationSubscribed_bloc.dart';

@immutable
abstract class OrganizationSubscribedBlocEvent {}


class GetOrganizationsSubscribed extends OrganizationSubscribedBlocEvent {}

class RemoveOrganization extends OrganizationSubscribedBlocEvent {
  final String id;
  RemoveOrganization({required this.id});
}