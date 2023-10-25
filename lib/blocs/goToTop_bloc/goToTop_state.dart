part of 'goToTop_bloc.dart';

@immutable
abstract class GoToTopState{}

class GoToTopInitial extends GoToTopState {}

class GoToTopShow extends GoToTopState {
  final bool show;
  GoToTopShow({required this.show});
}