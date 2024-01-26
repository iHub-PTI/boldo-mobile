import 'package:boldo/blocs/appointment_bloc/appointmentBloc.dart';
import 'package:boldo/models/News.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/screens/dashboard/tabs/components/appointment_card.dart';
import 'package:flutter/widgets.dart';
import './Doctor.dart';
import 'Patient.dart';

enum CancelUserReason {Patient, Practitioner}

class Appointment extends News {
  String? _status;
  String? id;
  String? start;
  String? end;
  String? description;
  Doctor? doctor;
  String? appointmentType;
  Patient? patient;
  Organization? organization;
  List<Prescription>? prescriptions;
  CancelUserReason? statusAutor;

  AppointmentStatus? _appointmentStatus;

  Appointment({
    this.id,
    this.start,
    this.end,
    this.description,
    this.doctor,
    String? status,
    this.prescriptions,
    this.organization,
    this.patient,
    this.appointmentType,
    this.statusAutor,
  }){
    _status = status;
    _appointmentStatus = statusesValid[status]?? statusDefault.value;
  }

  AppointmentStatus? get status => _appointmentStatus;
  set status(AppointmentStatus? newStatus){
    _appointmentStatus = AppointmentBloc.validChangeStatus(
      actualState: _appointmentStatus,
      newState: newStatus,
    );

    //set string status
    _status = statusesValid.entries.firstWhere(
            (element) => element.value == newStatus, orElse: () => statusDefault
    ).key;

    if(_appointmentStatus == AppointmentStatus.Cancelled){
      statusAutor = CancelUserReason.Patient;
    }
  }

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'],
    start: json['start'],
    end: json['end'],
    description: json['description'],
    status: json["status"],
    appointmentType: json["appointmentType"],
    doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
    organization: json['organization'] != null ? Organization.fromJson(json['organization']) : null,
    patient: json['patient'] != null ? Patient.fromJson(json['patient']): null,
    statusAutor: getCancelUserReason(statusAutor: json['statusAutor'] ),
  );

  static CancelUserReason? getCancelUserReason({String? statusAutor}){
    Map<String, CancelUserReason> _users = {
      'Patient': CancelUserReason.Patient,
      'Practitioner': CancelUserReason.Practitioner,
    };

    return _users[statusAutor];
  }

  String getCancelUserMessage(){
    Map<CancelUserReason, String> _users = {
      CancelUserReason.Patient: "Cancelado por el paciente",
      CancelUserReason.Practitioner: "Cancelado por el médico",
    };

    return _users[statusAutor]?? "Cancelado";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['start'] = start;
    data['end'] = end;
    data["status"] = _status;
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
      isInWaitingRoom: _status == "open",
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

  static MapEntry<String, AppointmentStatus>statusDefault = const MapEntry<String, AppointmentStatus>('locked', AppointmentStatus.Locked,);

}

enum AppointmentStatus {Upcoming, Open, Closed, Locked, Cancelled}