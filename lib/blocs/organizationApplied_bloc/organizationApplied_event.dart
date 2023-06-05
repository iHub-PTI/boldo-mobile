part of 'organizationApplied_bloc.dart';

@immutable
abstract class OrganizationAppliedBlocEvent {}

class GetOrganizationsPostulated extends OrganizationAppliedBlocEvent {
  final Patient patientSelected;
  GetOrganizationsPostulated({required this.patientSelected});
}

class UnPostulated extends OrganizationAppliedBlocEvent {
  final Patient patientSelected;
  final OrganizationRequest organization;
  UnPostulated({required this.organization, required this.patientSelected});
}
