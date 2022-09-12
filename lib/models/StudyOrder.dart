import 'dart:convert';

List<StudyOrder> studyOrderFromJson(dynamic str) =>
    List<StudyOrder>.from(str.map((x) => StudyOrder.fromJson(x)));

String studyOrderToJson(List<StudyOrder> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StudyOrder {
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
}

class Doctor {
  Doctor({
    this.biography,
    this.birthDate,
    this.email,
    this.familyName,
    this.gender,
    this.givenName,
    this.id,
    this.languages,
    this.phone,
    this.photoUrl,
    this.specializations,
    this.license
  });

  String? biography;
  DateTime? birthDate;
  String? email;
  String? familyName;
  String? gender;
  String? givenName;
  String? id;
  List<Language>? languages;
  String? phone;
  String? photoUrl;
  List<Language>? specializations;
  String? license;

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        birthDate: json["birthDate"] == null
            ? null
            : DateTime.parse(json["birthDate"]),
        email: json["email"] == null ? null : json["email"],
        familyName: json["familyName"] == null ? null : json["familyName"],
        gender: json["gender"] == null ? null : json["gender"],
        givenName: json["givenName"] == null ? null : json["givenName"],
        id: json["id"] == null ? null : json["id"],
        languages: json["languages"] == null
            ? null
            : List<Language>.from(
                json["languages"].map((x) => Language.fromJson(x))),
        phone: json["phone"] == null ? null : json["phone"],
        photoUrl: json["photoUrl"] == null ? null : json["photoUrl"],
        specializations: json["specializations"] == null
            ? null
            : List<Language>.from(
                json["specializations"].map((x) => Language.fromJson(x))),
        biography: json["biography"] == null ? null : json["biography"],
        license: json["license"] == null ? null : json["license"],
      );

  Map<String, dynamic> toJson() => {
        "birthDate": birthDate == null ? null : "${birthDate!.year.toString().padLeft(4, '0')}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}",
        "email": email == null ? null : email,
        "familyName": familyName == null ? null : familyName,
        "gender": gender == null ? null : gender,
        "givenName": givenName == null ? null : givenName,
        "id": id,
        "languages": languages == null ? null : List<dynamic>.from(languages!.map((x) => x.toJson())),
        "phone": phone == null ? null : phone,
        "photoUrl": photoUrl == null ? null : photoUrl,
        "specializations": specializations == null ? null : List<dynamic>.from(specializations!.map((x) => x.toJson())),
        "biography": biography == null ? null : biography,
        "license": license == null ? null : license,
      };
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
  ServiceRequest(
      {this.category,
      this.diagnosis,
      this.encounterId,
      this.identifier,
      this.urgent,
      this.notes});

  String? category;
  String? diagnosis;
  String? encounterId;
  String? identifier;
  bool? urgent;
  String? notes;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
      category: json["category"],
      diagnosis: json["diagnosis"],
      encounterId: json["encounterId"] == null ? null : json["encounterId"],
      identifier: json["identifier"],
      urgent: json["urgent"],
      notes: json["notes"] == null ? '' : json["notes"]);

  Map<String, dynamic> toJson() => {
        "category": category,
        "diagnosis": diagnosis,
        "encounterId": encounterId == null ? null : encounterId,
        "identifier": identifier,
        "urgent": urgent,
        "notes": notes == null ? null : notes,
      };
}
