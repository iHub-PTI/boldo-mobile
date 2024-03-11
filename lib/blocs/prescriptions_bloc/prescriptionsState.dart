part of 'prescriptionsBloc.dart';

@immutable
abstract class PrescriptionsState{}

class PrescriptionBlocInitial extends PrescriptionsState {}

class Loading extends PrescriptionsState {}

class Failed extends PrescriptionsState {
  final response;
  Failed({required this.response});
}

class EncounterWithPrescriptionsLoadedState extends PrescriptionsState {
  final List<Encounter> encounters;
  EncounterWithPrescriptionsLoadedState({required this.encounters});
}

class RedirectNextScreen extends PrescriptionsState {}

class Success extends PrescriptionsState {}
