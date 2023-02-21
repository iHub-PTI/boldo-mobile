part of 'doctor_availability_bloc.dart';

@immutable
abstract class DoctorAvailabilityEvent {}

class GetAvailability extends DoctorAvailabilityEvent {
  final String id;
  final String startDate;
  final String endDate;
  final List<Organization?>? organizations;
  GetAvailability({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.organizations,
  });
}