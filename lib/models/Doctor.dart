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
  NextAvailability? nextAvailability;

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
      this.nextAvailability});

  Doctor.fromJson(Map<String, dynamic> json,) {
    addressDescription = json['addressDescription'];
    biography = json['biography'];
    familyName = json['familyName'];
    gender = json['gender'];
    birthDate = json['birthDate'];
    city = json['city'];
    email = json['email'];
    identifier = json['identifier'];
    job = json['job'];
    phone = json['phone'];
    givenName = json['givenName'];
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
   if (json['nextAvailability'] != null) {
     nextAvailability = NextAvailability.fromJson(json["nextAvailability"]);
    }
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
    data['nextAvailability'] = nextAvailability;
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
