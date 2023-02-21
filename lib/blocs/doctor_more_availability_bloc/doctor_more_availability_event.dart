part of 'doctor_more_availability_bloc.dart';

@immutable
abstract class DoctorMoreAvailabilityEvent {}

class GetAvailability extends DoctorMoreAvailabilityEvent {
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