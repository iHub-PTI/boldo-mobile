part of 'organizationApplied_bloc.dart';

@immutable
abstract class OrganizationAppliedBlocEvent {}

class GetOrganizationsPostulated extends OrganizationAppliedBlocEvent {}

class UnPostulated extends OrganizationAppliedBlocEvent {
  final OrganizationRequest organization;
  UnPostulated({required this.organization});
}
