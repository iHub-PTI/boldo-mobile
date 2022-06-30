part of 'my_studies_bloc.dart';

@immutable
abstract class MyStudiesState {}

class MyStudiesInitial extends MyStudiesState {}

class Success extends MyStudiesState {
  //final String nameOfStudies;
  final List<String> studiesList;

  Success({required this.studiesList});
}

class Loading extends MyStudiesState {}

class Failed extends MyStudiesState {
  final String msg;

  Failed({required this.msg});
}
