import 'package:boldo/blocs/appointment_bloc/appointment_bloc.dart';
import 'package:boldo/core/core.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/News.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/screens/dashboard/tabs/components/appointment_card.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/widgets.dart';

/// types of user that can cancel an appointment
enum CancelUserReason {
  /// the patient
  patient,

  /// the doctor
  practitioner,
}

/// a medical consultation that is scheduled
class Appointment extends News {
  /// a medical consultation that is scheduled
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
  }) {
    _status = status;
    _appointmentStatus = statusesValid[status] ?? statusDefault.value;
  }

  ///
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      start: json['start'],
      end: json['end'],
      description: json['description'],
      status: json['status'],
      appointmentType: json['appointmentType'],
      doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'])
          : null,
      patient:
          json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      statusAutor: getCancelUserReason(statusAutor: json['statusAutor']),
    );
  }

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

  /// represent the category of speciality of the appointment
  Service? service;

  AppointmentStatus? get status => _appointmentStatus;
  set status(AppointmentStatus? newStatus) {
    _appointmentStatus = AppointmentBloc.validChangeStatus(
      actualState: _appointmentStatus,
      newState: newStatus,
    );

    //set string status
    _status = statusesValid.entries
        .firstWhere(
          (element) => element.value == newStatus,
          orElse: () => statusDefault,
        )
        .key;

    if (_appointmentStatus == AppointmentStatus.Cancelled) {
      statusAutor = CancelUserReason.patient;
    }
  }

  /// map string to [CancelUserReason]
  static CancelUserReason? getCancelUserReason({String? statusAutor}) {
    final usersAvailableToCancel = {
      'Patient': CancelUserReason.patient,
      'Practitioner': CancelUserReason.practitioner,
    };

    return usersAvailableToCancel[statusAutor];
  }

  /// obtain cancel reason based by user
  String getCancelUserMessage() {
    final reason = {
      CancelUserReason.patient: 'Cancelado por el paciente',
      CancelUserReason.practitioner: 'Cancelado por el médico',
    };

    return reason[statusAutor] ?? 'Cancelado';
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
  Widget show() {
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

  static Map<String?, AppointmentType> _typesValid = {
    'A': AppointmentType.InPerson,
    'V': AppointmentType.Virtual,
    'AV': AppointmentType.Both,
    'VA': AppointmentType.Both,
    null: AppointmentType.None,
  };

  static AppointmentType typeFromString({String? type}) {
    type = type?.toUpperCase();

    return _typesValid[type] ?? AppointmentType.None;
  }

  static String? typeString({required AppointmentType? type}) {
    return _typesValid.entries
        .firstWhere(
          (element) => element.value == type,
          orElse: () => const MapEntry(null, AppointmentType.None),
        )
        .key;
  }

  static MapEntry<String, AppointmentStatus> statusDefault =
      const MapEntry<String, AppointmentStatus>(
    'locked',
    AppointmentStatus.Locked,
  );

  static MapEntry<String?, AppointmentType> typeDefault =
      _typesValid.entries.last;
}

enum AppointmentStatus { Upcoming, Open, Closed, Locked, Cancelled }
