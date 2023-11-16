part of 'appointmentBloc.dart';

@immutable
abstract class AppointmentEvent {}

class GetAppointmentByEcounterId extends AppointmentEvent{
  final String encounterId;
  GetAppointmentByEcounterId({required this.encounterId});
}
