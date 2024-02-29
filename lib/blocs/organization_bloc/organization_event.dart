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
  final BuildContext context;
  SubscribeToAnManyOrganizations({
    required this.organizations,
    required this.patientSelected,
    required this.context,
  });
}

class GetOrganizationById extends OrganizationBlocEvent {
  final String id;
  GetOrganizationById({required this.id});
}

class GetAllOrganizationsByType extends OrganizationBlocEvent {
  final OrganizationType type;
  final String? name;
  final int page;
  final int? pageSize;
  GetAllOrganizationsByType({
    required this.type,
    this.name,
    this.page = 1,
    this.pageSize,
  });
}

class GetAllOrganizations extends OrganizationBlocEvent {
  final Patient patientSelected;
  GetAllOrganizations({required this.patientSelected});
}
