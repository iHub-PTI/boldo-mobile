import 'package:flutter/cupertino.dart';

class Appointment {
  String waitingRoomStatus;
  String id;
  String start;
  String end;
  String description;
  Doctor doctor;

  Appointment({
    @required this.id,
    @required this.start,
    @required this.end,
    this.description,
    @required this.doctor,
    @required this.waitingRoomStatus,
  });

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    start = json['start'];
    end = json['end'];
    description = json['description'];
    waitingRoomStatus = json["waitingRoomStatus"];
    doctor = json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['start'] = start;
    data['end'] = end;
    data["waitingRoomStatus"] = waitingRoomStatus;
    data['description'] = description;
    if (doctor != null) {
      data['doctor'] = doctor.toJson();
    }
    return data;
  }
}

class Doctor {
  String addressDescription;
  String birthDate;
  String city;
  String email;
  String familyName;
  String gender;
  String givenName;
  String id;
  String identifier;
  String job;
  String neighborhood;
  String phone;
  String photoUrl;
  String street;

  Doctor(
      {this.addressDescription,
      this.birthDate,
      this.city,
      this.email,
      this.familyName,
      this.gender,
      this.givenName,
      this.id,
      this.identifier,
      this.job,
      this.neighborhood,
      this.phone,
      this.photoUrl,
      this.street});

  Doctor.fromJson(Map<String, dynamic> json) {
    addressDescription = json['addressDescription'];
    birthDate = json['birthDate'];
    city = json['city'];
    email = json['email'];
    familyName = json['familyName'];
    gender = json['gender'];
    givenName = json['givenName'];
    id = json['id'];
    identifier = json['identifier'];
    job = json['job'];
    neighborhood = json['neighborhood'];
    phone = json['phone'];
    photoUrl = json['photoUrl'];
    street = json['street'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['addressDescription'] = addressDescription;
    data['birthDate'] = birthDate;
    data['city'] = city;
    data['email'] = email;
    data['familyName'] = familyName;
    data['gender'] = gender;
    data['givenName'] = givenName;
    data['id'] = id;
    data['identifier'] = identifier;
    data['job'] = job;
    data['neighborhood'] = neighborhood;
    data['phone'] = phone;
    data['photoUrl'] = photoUrl;
    data['street'] = street;
    return data;
  }
}
