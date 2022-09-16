import 'package:boldo/models/PresciptionMedicalRecord.dart';
import 'package:boldo/models/Soep.dart';

//List<MedicalRecord> patientMedicalRecordFromJson(dynamic str) => List<MedicalRecord>.from(str.map((x) => MedicalRecord.fromJson(x)));

class MedicalRecord {
  String? id;
  String? appointmentId;
  String? doctorId;
  String? instructions;
  String? diagnosis;
  String? mainReason;
  String? partOfEncounterId;
  String? patientId;
  Soep? soep;
  String? startTimeDate;
  String? status;
  List<PrescriptionMedicalRecord>? prescription;
  
  MedicalRecord({
    this.appointmentId,
    this.diagnosis,
    this.instructions,
    this.prescription
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
    prescription = json['prescriptions'] != null
        ? List<PrescriptionMedicalRecord>.from(json["prescriptions"]
            .map((x) => PrescriptionMedicalRecord.fromJson(x)))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['appointmentId'] = appointmentId;
    data['diagnosis'] = diagnosis;
    data['instructions'] = instructions;

    return data;
  }
}
