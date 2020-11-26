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
