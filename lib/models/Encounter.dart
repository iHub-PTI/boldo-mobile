import 'package:boldo/core/core.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/utils/helpers.dart';

/// An effective medical consultation
class Encounter {
  /// An effective medical consultation
  Encounter({
    this.appointmentId,
    this.diagnosis,
    this.instructions,
    this.encounterId,
    this.doctorId,
    this.doctor,
    this.patientId,
    String? encounterClassString,
    this.prescriptions,
    this.startTimeDate,
    this.finishTimeDate,
    this.mainReason,
    this.status,
    this.service,
  }) {
    _encounterClass = encounterClassString;
    encounterClass = Appointment.typeFromString(type: _encounterClass);
  }

  /// An effective medical consultation from a map
  factory Encounter.fromJson(Map<String, dynamic> json) {
    final doctor =
        json['doctorDto'] != null ? Doctor.fromJson(json['doctorDto']) : null;

    final prescriptions = json['prescriptions'] != null
        ? List<Prescription>.from(
            (json['prescriptions'] as List<Map<String, dynamic>>)
                .map(Prescription.fromJson),
          )
        : null;

    final start = json['startTimeDate'] != null
        ? DateTime.parse(json['startTimeDate'])
        : null;

    final end = json['finishTimeDate'] != null
        ? DateTime.parse(json['finishTimeDate'])
        : null;

    final service =
        json['service'] != null ? Service.fromJson(json['service']) : null;

    return Encounter(
      appointmentId: json['appointmentId'],
      diagnosis: json['diagnosis'],
      instructions: json['instructions'],
      encounterId: json['encounterId'],
      doctorId: json['encounterId'],
      doctor: doctor,
      patientId: json['patientId'],
      encounterClassString: json['encounterClass'],
      prescriptions: prescriptions,
      startTimeDate: start,
      finishTimeDate: end,
      mainReason: json['patientId'],
      status: json['status'],
      service: service,
    );
  }

  /// the FHIR id
  String? encounterId;

  /// the appointment scheduled origin id
  String? appointmentId;

  /// diagnosis from SOEP
  String? diagnosis;

  /// instructions from SOEP (for prescriptions)
  String? instructions;

  /// doctor id that make the anotations
  String? doctorId;

  /// the patient that participe in the encounter
  String? patientId;
  String? _encounterClass;

  /// status string of the consult
  String? status;

  /// main reason of the encounter
  String? mainReason;

  /// when the encounter start (input data)
  DateTime? startTimeDate;

  /// when the encounter end
  DateTime? finishTimeDate;

  /// modality of the encounter
  AppointmentType? encounterClass;

  /// doctor data
  Doctor? doctor;

  /// list of prescriptions
  List<Prescription>? prescriptions;

  /// represent the category of speciality of the appointment
  Service? service;
}
