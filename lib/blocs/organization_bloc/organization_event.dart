part of 'organization_bloc.dart';

@immutable
abstract class OrganizationBlocEvent {}

class SubscribeToAnOrganization extends OrganizationBlocEvent {
  final String id;
  SubscribeToAnOrganization({required this.id});
}

class SubscribeToAnManyOrganizations extends OrganizationBlocEvent {
  final List<Organization> organizations;
  final Patient patientSelected;
  SubscribeToAnManyOrganizations({required this.organizations, required this.patientSelected});
}

class GetOrganizationById extends OrganizationBlocEvent {
  final String id;
  GetOrganizationById({required this.id});
}

class GetAllOrganizations extends OrganizationBlocEvent {
  final Patient patientSelected;
  GetAllOrganizations({required this.patientSelected});
}
