part of 'doctor_availability_bloc.dart';

@immutable
abstract class DoctorAvailabilityEvent {}

class GetAvailability extends DoctorAvailabilityEvent {
  final AppointmentType appointmentType;
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final List<Organization?>? organizations;
  GetAvailability({
    required this.appointmentType,
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.organizations,
  });
}