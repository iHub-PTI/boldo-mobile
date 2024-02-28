part of 'organizationRequirementsValidate_bloc.dart';

@immutable
abstract class OrganizationRequirementsValidateState{}

class OrganizationRequirementsValidateInitial extends OrganizationRequirementsValidateState {
  final bool confirmedDataVeracity;
  OrganizationRequirementsValidateInitial({
    this.confirmedDataVeracity = false,
  });
}

class OrganizationRequirementsValidateLoading extends OrganizationRequirementsValidateState {}

class OrganizationRequirementsValidateFailed extends OrganizationRequirementsValidateState {
  final response;
  OrganizationRequirementsValidateFailed({required this.response});
}

class ValidateRequirementNeeded extends OrganizationRequirementsValidateState {
  final OrganizationRequirement requirement;
  final bool confirmedDataVeracity;
  final bool remarkNeedConfirmation;
  ValidateRequirementNeeded({
    required this.requirement,
    required this.confirmedDataVeracity,
    this.remarkNeedConfirmation = false,
  });
}

class OrganizationRequirementsValidateSuccess extends OrganizationRequirementsValidateState {}