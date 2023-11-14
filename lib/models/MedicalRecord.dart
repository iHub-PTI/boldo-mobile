import 'package:boldo/models/Prescription.dart';
import 'package:boldo/models/Soep.dart';
import 'package:boldo/models/StudyOrder.dart';

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
  List<Prescription>? prescription;
  List<ServiceRequest>? serviceRequests;
  
  MedicalRecord({
    this.appointmentId,
    this.diagnosis,
    this.instructions,
    this.prescription,
    this.serviceRequests
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
        ? List<Prescription>.from(json["prescriptions"]
            .map((x) => Prescription.fromJson(x)))
        : null;
    serviceRequests = json["serviceRequests"] == null
            ? List<ServiceRequest>.from([])
            : List<ServiceRequest>.from(
                json["serviceRequests"].map((x) => ServiceRequest.fromJson(x)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['appointmentId'] = appointmentId;
    data['diagnosis'] = diagnosis;
    data['instructions'] = instructions;

    return data;
  }
}
