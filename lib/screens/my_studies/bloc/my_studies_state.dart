part of 'my_studies_bloc.dart';

@immutable
abstract class MyStudiesState {}

class MyStudiesInitial extends MyStudiesState {}

class DiagnosticLoaded extends MyStudiesState {
  final List<DiagnosticReport> studiesList;

  DiagnosticLoaded({required this.studiesList});
}

class Loading extends MyStudiesState {}

class Failed extends MyStudiesState {
  final String msg;

  Failed({required this.msg});
}
