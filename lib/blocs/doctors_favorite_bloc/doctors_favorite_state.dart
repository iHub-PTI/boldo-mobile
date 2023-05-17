part of 'doctors_favorite_bloc.dart';

@immutable
abstract class FavoriteDoctorsState{}

class DoctorFavoriteInitial extends FavoriteDoctorsState {}

class LoadingFavoriteDoctors extends FavoriteDoctorsState {}

class LoadingMoreFavoriteDoctors extends FavoriteDoctorsState {}

class FailedFavoriteDoctors extends FavoriteDoctorsState {
  final response;
  FailedFavoriteDoctors({required this.response});
}

class SuccessFavoriteDoctors extends FavoriteDoctorsState {}

class FavoriteDoctorsLoaded extends FavoriteDoctorsState {
  final List<Doctor> doctors;
  FavoriteDoctorsLoaded({required this.doctors});
}

class MoreFavoriteDoctorsLoaded extends FavoriteDoctorsState {
  final List<Doctor> doctors;
  MoreFavoriteDoctorsLoaded({required this.doctors});
}