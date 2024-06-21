part of 'doctors_favorite_bloc.dart';

@immutable
abstract class FavoriteDoctorsEvent {}

class GetFavoriteDoctors extends FavoriteDoctorsEvent {
  GetFavoriteDoctors({
    required this.names,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
}

class GetMoreFavoriteDoctors extends FavoriteDoctorsEvent {
  GetMoreFavoriteDoctors({
    required this.offset,
    required this.names,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
  final int offset;
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
}

class SetFavoriteLocalDoctor extends FavoriteDoctorsEvent {
  SetFavoriteLocalDoctor({
    required this.doctor,
  });
  final Doctor doctor;
}
