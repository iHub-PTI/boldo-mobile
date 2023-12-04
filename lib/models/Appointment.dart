import 'package:boldo/models/News.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/screens/dashboard/tabs/components/appointment_card.dart';
import 'package:flutter/widgets.dart';
import './Doctor.dart';
import 'Patient.dart';

class Appointment extends News {
  String? status;
  String? id;
  String? start;
  String? end;
  String? description;
  Doctor? doctor;
  String? appointmentType;
  Patient? patient;
  Organization? organization;
  List<Prescription>? prescriptions;

  AppointmentStatus? _appointmentStatus;

  Appointment({
    this.id,
    this.start,
    this.end,
    this.description,
    this.doctor,
    this.status,
    this.prescriptions,
    this.organization,
    this.patient,
  });

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    start = json['start'];
    end = json['end'];
    description = json['description'];
    status = json["status"];
    appointmentType = json["appointmentType"];
    doctor = json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null;
    organization = json['organization'] != null ? Organization.fromJson(json['organization']) : null;
    patient = json['patient'] != null ? Patient.fromJson(json['patient']): null;
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
    data["appointmentType"] = appointmentType;
    return data;
  }

  @override
  Widget show(){
    return AppointmentCard(
      appointment: this,
      isInWaitingRoom: status == "open",
      showCancelOption: true,
    );
  }

  static Map<String, AppointmentStatus> statusesValid = {
    'upcoming': AppointmentStatus.Upcoming,
    'open': AppointmentStatus.Open,
    'closed': AppointmentStatus.Closed,
    'locked': AppointmentStatus.Locked,
    'cancelled': AppointmentStatus.Cancelled,
  };

  static MapEntry<String, AppointmentStatus>statusDefault = const MapEntry<String, AppointmentStatus>('closed', AppointmentStatus.Locked,);

}

enum AppointmentStatus {Upcoming, Open, Closed, Locked, Cancelled}