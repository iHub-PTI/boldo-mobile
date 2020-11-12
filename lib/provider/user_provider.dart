import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _givenName,
      _familyName,
      _birthDate,
      _job,
      _gender,
      _email,
      _phone,
      _street,
      _neighborhood,
      _city,
      _addressDescription;

  String get getGivenName => _givenName;
  String get getFamilyName => _familyName;
  String get getBirthDate => _birthDate;
  String get getJob => _job;
  String get getGender => _gender;
  String get getEmail => _email;
  String get getPhone => _phone;
  String get getStreet => _street;
  String get getNeighborhood => _neighborhood;
  String get getCity => _city;
  String get getAddressDescription => _addressDescription;

  void setUserData({
    String givenName,
    String familyName,
    String birthDate,
    String job,
    String gender,
    String email,
    String phone,
    String street,
    String neighborhood,
    String city,
    String addressDescription,
    bool notify = false,
  }) {
    _givenName = givenName ?? _givenName;
    _familyName = familyName ?? _familyName;
    _birthDate = birthDate ?? _birthDate;
    _job = job ?? _job;
    _gender = gender ?? _gender;
    _email = email ?? _email;
    _phone = phone ?? _phone;
    _street = street ?? _street;
    _neighborhood = neighborhood ?? _neighborhood;
    _city = city ?? _city;
    _addressDescription = addressDescription ?? _addressDescription;

    if (notify) {
      notifyListeners();
    }
  }
}
