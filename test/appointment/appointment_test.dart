import 'package:boldo/blocs/appointment_bloc/appointmentBloc.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
    test('Change appointment status from open to closed', () {

      // initial status
      final Appointment _appointment = Appointment(
          status: 'open'
      );

      AppointmentStatus? Function() changeStatus = () {
        _appointment.status= AppointmentStatus.Closed;
        return _appointment.status;
      };

      expect(changeStatus.call(), AppointmentStatus.Closed);
    });

    test('Change appointment status from open to cancelled', () {
      // initial status
      final Appointment _appointment = Appointment(
          status: 'open'
      );

      AppointmentStatus? Function() changeStatus = () {
        _appointment.status= AppointmentStatus.Cancelled;
        return _appointment.status;
      };

      expect(changeStatus.call(), AppointmentStatus.Cancelled);
    });

    test('Change appointment status from open to locked', () {
      // initial status
      final Appointment _appointment = Appointment(
          status: 'open'
      );

      AppointmentStatus? Function() changeStatus = () {
        _appointment.status= AppointmentStatus.Locked;
        return _appointment.status;
      };

      expect(changeStatus.call(), AppointmentStatus.Locked);
    });

    test('Change appointment status from locked to cancelled', () {
      // initial status
      final Appointment _appointment = Appointment(
          status: 'locked'
      );

      AppointmentStatus? Function() changeStatus = () {
        _appointment.status= AppointmentStatus.Cancelled;
        return _appointment.status;
      };

      expect(() => changeStatus.call(), throwsA(isA<InvalidAppointmentStatusChange>()));
    });
}