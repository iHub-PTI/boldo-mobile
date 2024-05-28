import 'package:boldo/core/core.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/models/Soep.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/utils/helpers.dart';

/// An effective medical consultation
class Encounter {
  /// An effective medical consultation
  Encounter({
    this.id,
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
    this.partOfEncounterId,
    this.soep,
    this.serviceRequests,
  }) {
    _encounterClass = encounterClassString;
    encounterClass = Appointment.typeFromString(type: _encounterClass);
  }

  /// An effective medical consultation from a map
  factory Encounter.fromJson(Map<String, dynamic> json) {
    final id = json['doctorDto'] as String?;

    final doctor =
        json['doctorDto'] != null ? Doctor.fromJson(json['doctorDto']) : null;

    List<Prescription>? prescriptions;
    if (json['prescriptions'] != null) {
      prescriptions = [];
      for (final v in json['prescriptions'] as List<dynamic>) {
        prescriptions.add(Prescription.fromJson(v));
      }
    }

    final start = json['startTimeDate'] != null
        ? DateTime.parse(json['startTimeDate']).toLocal()
        : null;

    final end = json['finishTimeDate'] != null
        ? DateTime.parse(json['finishTimeDate']).toLocal()
        : null;

    final service =
        json['service'] != null ? Service.fromJson(json['service']) : null;

    final partOfEncounterId = json['partOfEncounterId'] as String?;

    final soep = json['soep'] != null ? Soep.fromJson(json['soep']) : null;

    List<ServiceRequest>? serviceRequests;
    if (json['serviceRequests'] != null) {
      serviceRequests = [];
      for (final v in json['serviceRequests'] as List<dynamic>) {
        serviceRequests.add(ServiceRequest.fromJson(v));
      }
    }

    return Encounter(
      id: id,
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
      partOfEncounterId: partOfEncounterId,
      soep: soep,
      serviceRequests: serviceRequests,
    );
  }

  /// the FHIR id of this object
  String? id;

  /// the FHIR id of this object
  String? encounterId;

  /// the appointment scheduled origin id
  String? appointmentId;

  /// diagnosis from SOEP
  String? diagnosis;

  /// instructions from SOEP (for prescriptions)
  String? instructions;

  /// doctor id that make the annotations
  String? doctorId;

  /// the patient that participate in the encounter
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

  /// represent the category of specialty of the appointment
  Service? service;

  /// FHIR id of the encounter that related this object with a principal
  /// appointment
  String? partOfEncounterId;

  /// the annotations of the [Doctor] in the encounter
  Soep? soep;

  /// The list of prescriptions emitted in the encounter
  List<Prescription>? prescription;

  /// The list of the studies orders
  List<ServiceRequest>? serviceRequests;
}
