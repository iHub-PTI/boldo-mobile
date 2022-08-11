part of 'passportBloc.dart';

@immutable
abstract class PassportState {}

class PassportInitial extends PassportState {}

class Failed extends PassportState {
  final String response;

  Failed({required this.response});
}

class Loading extends PassportState {}

class Success extends PassportState {}
