part of 'doctor_more_availability_bloc.dart';

@immutable
abstract class DoctorMoreAvailabilityEvent {}

class GetAvailability extends DoctorMoreAvailabilityEvent {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final List<Organization?>? organizations;
  final AppointmentType appointmentType;
  GetAvailability({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.organizations,
    required this.appointmentType,
  });
}