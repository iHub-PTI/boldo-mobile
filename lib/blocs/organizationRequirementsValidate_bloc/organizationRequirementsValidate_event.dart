part of 'organizationRequirementsValidate_bloc.dart';

@immutable
abstract class OrganizationRequirementsValidateEvent {}

class ValidateRequirement extends OrganizationRequirementsValidateEvent {
  final BuildContext context;
  final bool answer;
  final bool confirmedDataVeracity;
  ValidateRequirement({
    required this.context,
    required this.answer,
    required this.confirmedDataVeracity,
  });
}

class ConfirmVeracity extends OrganizationRequirementsValidateEvent {
  final BuildContext context;
  final bool confirmedDataVeracity;
  ConfirmVeracity({
    required this.context,
    required this.confirmedDataVeracity,
  });
}

class InitValidation extends OrganizationRequirementsValidateEvent {
  final BuildContext context;
  final bool confirmedDataVeracity;
  // final List<OrganizationRequirement> requirements;
  InitValidation({
    required this.context,
    // required this.requirements,
    this.confirmedDataVeracity = false,
  });
}

