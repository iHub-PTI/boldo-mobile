part of 'favorite_action_bloc.dart';

@immutable
abstract class FavoriteActionEvent {}

class PutFavoriteStatus extends FavoriteActionEvent {
  final Doctor doctor;
  final bool favoriteStatus;
  PutFavoriteStatus({
    required this.doctor,
    required this.favoriteStatus,
  });
}