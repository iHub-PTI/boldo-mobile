import 'package:boldo/utils/helpers.dart';

import 'Appointment.dart';
import 'Doctor.dart';
import 'Prescription.dart';

class Encounter {
  String? encounterId;
  String? appointmentId;
  String? diagnosis;
  String? instructions;
  String? doctorId;
  String? patientId;
  String? _encounterClass;
  String? status;
  String? mainReason;
  DateTime? startTimeDate;
  DateTime? finishTimeDate;

  AppointmentType? encounterClass;

  Doctor? doctor;

  List<Prescription>? prescriptions;

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
  }){
    _encounterClass = encounterClassString;
    encounterClass = Appointment.typeFromString(type: _encounterClass);
  }

  factory Encounter.fromJson(Map<String, dynamic> json) {

    Doctor? _doctor = json['doctorDto'] != null
        ? Doctor.fromJson(json['doctorDto']): null;

    List<Prescription>? _prescriptions = json['prescriptions'] != null
        ? List<Prescription>.from(json["prescriptions"]
        .map((x) => Prescription.fromJson(x)))
        : null;

    DateTime? _start = json['startTimeDate'] != null ? DateTime.parse(
        json['startTimeDate']) : null;

    DateTime? _end = json['finishTimeDate'] != null ? DateTime.parse(
        json['finishTimeDate']) : null;

    return Encounter(
      appointmentId: json['appointmentId'],
      diagnosis: json['diagnosis'],
      instructions: json['instructions'],
      encounterId: json['encounterId'],
      doctorId: json['encounterId'],
      doctor: _doctor,
      patientId: json['patientId'],
      encounterClassString: json['encounterClass'],
      prescriptions: _prescriptions,
      startTimeDate: _start,
      finishTimeDate: _end,
      mainReason: json['patientId'],
      status: json['status'],
    );

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['appointmentId'] = appointmentId;
    data['diagnosis'] = diagnosis;
    data['instructions'] = instructions;

    return data;
  }
}
