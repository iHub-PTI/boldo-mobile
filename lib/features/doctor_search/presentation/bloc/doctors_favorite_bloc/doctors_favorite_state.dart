part of 'doctors_favorite_bloc.dart';

@immutable
abstract class FavoriteDoctorsState {}

class DoctorFavoriteInitial extends FavoriteDoctorsState {}

class LoadingFavoriteDoctors extends FavoriteDoctorsState {}

class LoadingMoreFavoriteDoctors extends FavoriteDoctorsState {}

class FailedFavoriteDoctors extends FavoriteDoctorsState {
  FailedFavoriteDoctors({required this.response});
  final String response;
}

class FavoriteDoctorsAdded extends FavoriteDoctorsState {
  FavoriteDoctorsAdded({required this.doctor});
  final Doctor doctor;
}

class FavoriteDoctorsLoaded extends FavoriteDoctorsState {
  FavoriteDoctorsLoaded({required this.doctors});
  final PagList<Doctor> doctors;
}

class MoreFavoriteDoctorsLoaded extends FavoriteDoctorsState {
  MoreFavoriteDoctorsLoaded({required this.doctors});
  final PagList<Doctor> doctors;
}
