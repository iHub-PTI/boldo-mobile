part of 'appointment_bloc.dart';

/// State for [AppointmentBloc]
@immutable
abstract class AppointmentEvent {}

/// Event that obtain an [Appointment] by an encounterId
class GetAppointmentByEcounterId extends AppointmentEvent {
  /// Event that obtain an [Appointment] by an encounterId
  GetAppointmentByEcounterId({required this.encounterId});

  /// The [encounterId] asociated with the [Appointment] expected
  final String encounterId;
}
