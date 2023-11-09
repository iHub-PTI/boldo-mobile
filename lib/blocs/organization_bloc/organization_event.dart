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

class GetAllOrganizationsByType extends OrganizationBlocEvent {
  final OrganizationType type;
  final String? name;
  GetAllOrganizationsByType({required this.type, this.name});
}

class GetAllOrganizations extends OrganizationBlocEvent {
  final Patient patientSelected;
  GetAllOrganizations({required this.patientSelected});
}
