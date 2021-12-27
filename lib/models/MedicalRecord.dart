import 'package:boldo/models/Soep.dart';

class MedicalRecord {
  String id;
  String appointmentId;
  String doctorId;
  String instructions;
  String diagnosis;
  String mainReason;
  String partOfEncounterId;
  String patientId;
  Soep soep;
  String startTimeDate;
  String status;

  MedicalRecord({
    this.appointmentId,
    this.diagnosis,
    this.instructions,
  });

  MedicalRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appointmentId = json['appointmentId'];
    diagnosis = json['diagnosis'];
    instructions = json['instructions'];
    doctorId = json['doctorId'];
    mainReason = json['mainReason'];
    partOfEncounterId = json['partOfEncounterId'];
    patientId = json['patientId'];
    soep = json['soep'] != null ? Soep.fromJson(json['soep']) : null;
    startTimeDate = json['startTimeDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['appointmentId'] = appointmentId;
    data['diagnosis'] = diagnosis;
    data['instructions'] = instructions;

    return data;
  }
}
