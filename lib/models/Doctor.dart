import 'package:boldo/models/Organization.dart';
import 'package:boldo/utils/helpers.dart';

class Doctor {
  String? addressDescription;
  String? biography;
  String? familyName;
  String? gender;
  String? birthDate;
  String? city;
  String? email;
  String? identifier;
  String? job;
  String? phone;
  String? givenName;
  String? id;
  List<Languages>? languages;
  String? license;
  String? neighborhood;
  String? photoUrl;
  List<Specializations>? specializations;
  String? street;
  List<OrganizationWithAvailability>? organizations;
  bool isFavorite = false;

  Doctor(
      {this.addressDescription,
      this.biography,
      this.familyName,
      this.gender,
      this.birthDate,
      this.city,
      this.email,
      this.identifier,
      this.job,
      this.phone,
      this.givenName,
      this.id,
      this.languages,
      this.license,
      this.neighborhood,
      this.photoUrl,
      this.specializations,
      this.street,
      this.organizations,
      this.isFavorite = false,
      });

  Doctor.fromJson(Map<String, dynamic> json,) {
    addressDescription = json['addressDescription'];
    biography = json['biography'];
    familyName = json['familyName']!= null ? toLowerCase(json['familyName']!) : null;
    gender = json['gender'];
    birthDate = json['birthDate'];
    city = json['city'];
    email = json['email'];
    identifier = json['identifier'];
    job = json['job'];
    phone = json['phone'];
    givenName = json['givenName']!= null ? toLowerCase(json['givenName']!) : null;
    id = json['id'];
    if (json['languages'] != null) {
      languages = [];
      json['languages'].forEach((v) {
        languages!.add(Languages.fromJson(v));
      });
    }
    license = json['license'];
    neighborhood = json['neighborhood'];
    photoUrl = json['photoUrl'];
    if (json['specializations'] != null) {
      specializations = [];
      json['specializations'].forEach((v) {
        specializations!.add(Specializations.fromJson(v));
      });
    }
    street = json['street'];
    if (json['organizations'] != null) {
      organizations = [];
      json['organizations'].forEach((v) {
        organizations!.add(OrganizationWithAvailability.fromJson(v));
      });
    }
    isFavorite = json['isFavorite']?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['addressDescription'] = addressDescription;
    data['biography'] = biography;
    data['familyName'] = familyName;
    data['gender'] = gender;
    data['birthDate'] = birthDate;
    data['city'] = city;
    data['email'] = email;
    data['identifier'] = identifier;
    data['job'] = job;
    data['phone'] = phone;
    data['givenName'] = givenName;
    data['id'] = id;
    if (languages != null) {
      data['languages'] = languages!.map((v) => v.toJson()).toList();
    }
    data['license'] = license;
    data['neighborhood'] = neighborhood;
    data['photoUrl'] = photoUrl;
    if (specializations != null) {
      data['specializations'] =
          specializations!.map((v) => v.toJson()).toList();
    }
    data['street'] = street;
    if (organizations != null) {
      data['organizations'] =
          organizations!.map((v) => v.toJson()).toList();
    }
    data['isFavorite'] = isFavorite;
    return data;
  }
}

class Languages {
  String? description;
  String? id;

  Languages({this.description, this.id});

  Languages.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['description'] = description;
    data['id'] = id;
    return data;
  }
}

class Specializations {
  String? description;
  String? id;

  Specializations({this.description, this.id});

  Specializations.fromJson(Map<String, dynamic> json) {
    description = toLowerCase(json['description']!);
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['description'] = description;
    data['id'] = id;
    return data;
  }
}

class NextAvailability {
  String? availability;
  String? appointmentType;

  NextAvailability({this.availability, this.appointmentType});

  NextAvailability.fromJson(Map<String, dynamic> json) {
    availability = json['availability'];
    appointmentType = json['appointmentType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['availability'] = availability;
    data['appointmentType'] = appointmentType;
    return data;
  }
}

class OrganizationWithAvailability{

  Organization? organization;
  List<NextAvailability?>? availabilities;

  OrganizationWithAvailability.fromJson(Map<String, dynamic> json) {
    organization = Organization.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data.addAll(organization?.toJson()?? {});
    return data;
  }

}

class OrganizationWithAvailabilities{

  String? idOrganization,
  nameOrganization;
  NextAvailability? nextAvailability;
  List<NextAvailability?> availabilities = [];

  OrganizationWithAvailabilities.fromJson(Map<String, dynamic> json) {
    idOrganization = json['idOrganization'];
    nameOrganization = json['nameOrganization'];
    if (json['nextAvailability'] != null) {
      nextAvailability = NextAvailability.fromJson(json["nextAvailability"]);
    }
    if (json['availabilities'] != null) {
      json['availabilities'].forEach((v) {
        availabilities.add(NextAvailability.fromJson(v));
      });
    }
  }

}


