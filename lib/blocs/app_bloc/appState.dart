part of 'appBloc.dart';

@immutable
abstract class AppState{}

class AppInitial extends AppState {}

class Loading extends AppState {}

class Failed extends AppState {
  final response;
  Failed({required this.response});
}

class Success extends AppState {}
