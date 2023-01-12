part of 'home_bloc.dart';

@immutable
abstract class HomeState{}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeFailed extends HomeState {
  final response;
  HomeFailed({required this.response});
}

class HomeSuccess extends HomeState {}