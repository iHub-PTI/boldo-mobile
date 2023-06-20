part of 'doctors_recent_bloc.dart';

@immutable
abstract class RecentDoctorsEvent {}

class GetRecentDoctors extends RecentDoctorsEvent {
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
  GetRecentDoctors({
    required this.names,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
}