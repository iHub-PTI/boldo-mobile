part of 'goToTop_bloc.dart';

@immutable
abstract class GoToTopEvent {}

class GoToTopVisibility extends GoToTopEvent {
  final bool show;
  GoToTopVisibility({
    required this.show,
  });
}