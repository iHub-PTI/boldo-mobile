part of 'favorite_action_bloc.dart';

@immutable
abstract class FavoriteActionState{}

class DoctorAvailabilityInitial extends FavoriteActionState {}

class LoadingFavoriteAction extends FavoriteActionState {}

class FailedFavoriteAction extends FavoriteActionState {
  final response;
  FailedFavoriteAction({required this.response});
}

class SuccessFavoriteAction extends FavoriteActionState {}