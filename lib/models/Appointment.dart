import 'package:boldo/models/Prescription.dart';
import 'package:flutter/cupertino.dart';
import './Doctor.dart';

class Appointment {
  String? status;
  String? id;
  String? start;
  String? end;
  String? description;
  Doctor? doctor;
  List<Prescription>? prescriptions;

  Appointment({
    this.id,
    this.start,
    this.end,
    this.description,
    this.doctor,
    this.status,
    this.prescriptions,
  });

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    start = json['start'];
    end = json['end'];
    description = json['description'];
    status = json["status"];
    doctor = json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['start'] = start;
    data['end'] = end;
    data["status"] = status;
    data['description'] = description;
    if (doctor != null) {
      data['doctor'] = doctor!.toJson();
    }
    return data;
  }
}
