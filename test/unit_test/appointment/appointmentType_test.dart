import 'package:boldo/models/Appointment.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group("appointment status from string", () {

    test('Appointment type virtual', () {

      String? stringStatus = 'V';

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.Virtual);
    });

    test('Appointment type inperson', () {

      String? stringStatus = 'A';

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.InPerson);
    });

    test('Appointment type both', () {

      String? stringStatus = 'AV';

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.Both);
    });

    test('Appointment type both inverted', () {

      String? stringStatus = 'VA';

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.Both);
    });

    test('Appointment type null', () {

      String? stringStatus;

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.None);
    });

    test('Appointment type unknown', () {

      String? stringStatus = 'P';

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.None);
    });

  });

  group("appointment status from lower string", () {

    test('Appointment type virtual', () {

      String? stringStatus = 'v';

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.Virtual);
    });

    test('Appointment type inperson', () {

      String? stringStatus = 'a';

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.InPerson);
    });

    test('Appointment type both', () {

      String? stringStatus = 'av';

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.Both);
    });

    test('Appointment type both inverted', () {

      String? stringStatus = 'va';

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.Both);
    });

    test('Appointment type null', () {

      String? stringStatus;

      // initial status
      final AppointmentType? appointmentType = Appointment.typeFromString(type: stringStatus);

      expect(appointmentType, AppointmentType.None);
    });

  });

  group("appointment status to string", () {

    test('Appointment type virtual', () {

      AppointmentType? status = AppointmentType.Virtual;

      // initial status
      final String? appointmentType = Appointment.typeString(type: status);

      expect(appointmentType, "V");
    });

    test('Appointment type inperson', () {

      AppointmentType? status = AppointmentType.InPerson;

      // initial status
      final String? appointmentType = Appointment.typeString(type: status);

      expect(appointmentType, "A");
    });

    test('Appointment type both', () {

      AppointmentType? status = AppointmentType.Both;

      // initial status
      final String? appointmentType = Appointment.typeString(type: status);

      expect(appointmentType, "AV");
    });

    test('Appointment type none', () {

      AppointmentType? status = AppointmentType.None;

      // initial status
      final String? appointmentType = Appointment.typeString(type: status);

      expect(appointmentType, null);
    });

    test('Appointment type null', () {

      AppointmentType? status;

      // initial status
      final String? appointmentType = Appointment.typeString(type: status);

      expect(appointmentType, null);
    });

  });

}