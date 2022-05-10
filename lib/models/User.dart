import '../utils/helpers.dart';

class User {
  String? givenName,
      familyName,
      birthDate,
      gender,
      phone,
      photoUrl,
      identifier,
      password,
      relationshipCode,
      relationshipDisplaySpan;

  bool isNew;

  User(
      {this.givenName,
        this.familyName,
        this.birthDate,
        this.gender,
        this.phone,
        this.photoUrl,
        this.identifier,
        this.password,
        this.relationshipCode,
        this.isNew = true});

  factory User.fromJson(Map<String, dynamic> json,) => User(
      givenName : json['givenName']!= null ? toLowerCase(json['givenName']!) : null,
      familyName : json['familyName']!= null ? toLowerCase(json['familyName']!) : null,
      birthDate : json['birthDate'].toString(),
      gender : spanishGenderToEnglish(json['gender']),
      photoUrl : json['photoUrl'],
      identifier : json['identifier'],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['familyName'] = familyName;
    data['gender'] = gender;
    data['birthDate'] = birthDate;
    data['phone'] = phone;
    data['givenName'] = givenName;
    data['photoUrl'] = photoUrl;
    data['identifier'] = identifier;
    data['relationshipCode'] = relationshipCode;
    return data;
  }

  Map<String, dynamic> toJsonNewPatient() {
    final Map<String, dynamic> data = {};
    data['familyName'] = familyName;
    data['gender'] = gender;
    data['birthDate'] = birthDate;
    //data['phone'] = phone;
    data['givenName'] = givenName;
    data['photoUrl'] = photoUrl;
    data['identifier'] = identifier;
    data['relationshipCode'] = relationshipCode;
    return data;
  }

  Map<String, dynamic> toJsonExistPatient() {
    final Map<String, dynamic> data = {};
    data['identifier'] = identifier;
    data['relationshipCode'] = relationshipCode;
    return data;
  }
}
