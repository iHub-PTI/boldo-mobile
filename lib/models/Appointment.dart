import 'package:flutter/cupertino.dart';
import './Doctor.dart';

class Appointment {
  String status;
  String id;
  String start;
  String end;
  String description;
  String reason;
  Doctor doctor;

  Appointment({
    @required this.id,
    @required this.start,
    @required this.end,
    this.description,
    this.reason,
    @required this.doctor,
    @required this.status,
  });

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    start = json['start'];
    end = json['end'];
    description = json['description'];
    status = json["status"];
    reason = json["reason"];
    doctor = json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['start'] = start;
    data['end'] = end;
    data["status"] = status;
    data['description'] = description;
    data['reason'] = reason;
    if (doctor != null) {
      data['doctor'] = doctor.toJson();
    }
    return data;
  }
}
