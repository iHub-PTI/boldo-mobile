part of 'doctor_bloc.dart';

@immutable
abstract class DoctorEvent {}

class GetAvailability extends DoctorEvent {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final List<Organization?>? organizations;
  GetAvailability({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.organizations,
  });
}

class GetDoctor extends DoctorEvent {
  final String id;
  GetDoctor({required this.id});
}