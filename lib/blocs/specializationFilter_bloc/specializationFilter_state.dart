part of 'specializationFilter_bloc.dart';

@immutable
abstract class SpecializationFilterState{}

class SpecializationFilterInitial extends SpecializationFilterState {}

class LoadingSpecializationFilter extends SpecializationFilterState {}

class FailedSpecializationFilter extends SpecializationFilterState {
  final response;
  FailedSpecializationFilter({required this.response});
}

class SuccessSpecializationFilter extends SpecializationFilterState {
  final List<Specializations> specializationsList;
  SuccessSpecializationFilter({required this.specializationsList});
}
