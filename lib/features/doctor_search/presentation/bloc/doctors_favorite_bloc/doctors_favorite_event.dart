part of 'doctors_favorite_bloc.dart';

@immutable
abstract class FavoriteDoctorsEvent {}

class GetFavoriteDoctors extends FavoriteDoctorsEvent {
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
  GetFavoriteDoctors({
    required this.names,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
}

class GetMoreFavoriteDoctors extends FavoriteDoctorsEvent {
  final int offset;
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
  GetMoreFavoriteDoctors({
    required this.offset,
    required this.names,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
}