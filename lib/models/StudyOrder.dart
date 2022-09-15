import 'dart:convert';

import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/News.dart';
import 'package:boldo/screens/dashboard/tabs/components/study_order_card.dart';
import 'package:flutter/cupertino.dart';

List<StudyOrder> studyOrderFromJson(dynamic str) =>
    List<StudyOrder>.from(str.map((x) => StudyOrder.fromJson(x)));

String studyOrderToJson(List<StudyOrder> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StudyOrder extends News {
  StudyOrder({
    this.authoredDate,
    this.doctor,
    this.encounterId,
    this.serviceRequests,
    this.serviceRequestsCount,
  });

  String? authoredDate;
  Doctor? doctor;
  String? encounterId;
  List<ServiceRequest>? serviceRequests;
  int? serviceRequestsCount;

  factory StudyOrder.fromJson(Map<String, dynamic> json) => StudyOrder(
        authoredDate: json["authoredDate"],
        doctor: Doctor.fromJson(json["doctor"]),
        encounterId: json["encounterId"] == null ? null : json["encounterId"],
        serviceRequests: json["serviceRequests"] == null
            ? null
            : List<ServiceRequest>.from(
                json["serviceRequests"].map((x) => ServiceRequest.fromJson(x))),
        serviceRequestsCount: json["serviceRequestsCount"],
      );

  Map<String, dynamic> toJson() => {
        "authoredDate": authoredDate,
        "doctor": doctor!.toJson(),
        "encounterId": encounterId,
        "serviceRequests": serviceRequests == null
            ? null
            : List<dynamic>.from(serviceRequests!.map((x) => x.toJson())),
        "serviceRequestsCount": serviceRequestsCount,
      };

  @override
  Widget show() {
    return StudyOrderCard(
      studyOrder: this,
    );
  }
}
class Language {
  Language({
    this.description,
    this.id,
  });

  String? description;
  String? id;

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        description: json["description"] == null ? null : json["description"],
        id: json["id"] == null ? null : json["id"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "id": id,
      };
}

class ServiceRequest {
  ServiceRequest({
    this.authoredDate,
    this.category,
    this.description,
    this.diagnosis,
    this.diagnosticReportCount,
    this.encounterId,
    this.id,
    this.identifier,
    this.urgent,
    this.notes,
  });

  String? id;
  String? authoredDate;
  String? category;
  String? description;
  String? diagnosis;
  String? encounterId;
  String? identifier;
  bool? urgent;
  String? notes;
  int? diagnosticReportCount;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
      authoredDate: json["authoredDate"],
      category: json["category"],
      description: json["description"],
      diagnosis: json["diagnosis"],
      diagnosticReportCount: json["diagnosticReportCount"],
      encounterId: json["encounterId"] == null ? null : json["encounterId"],
      id: json["id"],
      identifier: json["identifier"],
      urgent: json["urgent"],
      notes: json["notes"] == null ? '' : json["notes"]);

  Map<String, dynamic> toJson() => {
        "authoredDate": authoredDate,
        "category": category,
        "description": description,
        "diagnosis": diagnosis,
        "diagnosticReportCount": diagnosticReportCount,
        "encounterId": encounterId == null ? null : encounterId,
        "id": id,
        "identifier": identifier,
        "urgent": urgent,
        "notes": notes == null ? null : notes,
      };
}
