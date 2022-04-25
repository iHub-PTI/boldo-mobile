class Patient {
  String? givenName,
      familyName,
      birthDate,
      job,
      gender,
      email,
      phone,
      street,
      neighborhood,
      city,
      addressDescription,
      photoUrl,
      id,
      identifier;

  Patient(
      {this.id,
        this.givenName,
        this.familyName,
        this.birthDate,
        this.gender,
        this.city,
        this.email,
        this.job,
        this.phone,
        this.neighborhood,
        this.photoUrl,
        this.street,
        this.identifier});

  Patient.fromJson(Map<String, dynamic> json,) {
    givenName = json['givenName'];
    familyName = json['familyName'];
    birthDate = json['birthDate'];
    job = json['job'];
    gender = json['gender'];
    email = json['email'];
    phone = json['phone'];
    street = json['street'];
    neighborhood = json['neighborhood'];
    city = json['city'];
    addressDescription = json['addressDescription'];
    photoUrl = json['photoUrl'];
    id = json['id'];
    identifier = json['identifier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['addressDescription'] = addressDescription;
    data['familyName'] = familyName;
    data['gender'] = gender;
    data['birthDate'] = birthDate;
    data['city'] = city;
    data['email'] = email;
    data['job'] = job;
    data['phone'] = phone;
    data['givenName'] = givenName;
    data['id'] = id;
    data['neighborhood'] = neighborhood;
    data['photoUrl'] = photoUrl;
    data['street'] = street;
    data['identifier'] = identifier;
    return data;
  }
}
