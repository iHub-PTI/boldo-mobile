import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _givenName,
      _familyName,
      _birthDate,
      _job,
      _gender,
      _email,
      _phone,
      _street,
      _neighborhood,
      _city,
      _addressDescription,
      _photoUrl;

  String? _profileEditSuccessMessage;
  String? _profileEditErrorMessage;

  String? get getGivenName => _givenName;
  String? get getFamilyName => _familyName;
  String? get getBirthDate => _birthDate;
  String? get getJob => _job;
  String? get getGender => _gender;
  String? get getEmail => _email;
  String? get getPhone => _phone;
  String? get getStreet => _street;
  String? get getNeighborhood => _neighborhood;
  String? get getCity => _city;
  String? get getAddressDescription => _addressDescription;
  String? get getPhotoUrl => _photoUrl;

  String? get profileEditSuccessMessage => _profileEditSuccessMessage;
  String? get profileEditErrorMessage => _profileEditErrorMessage;

  void clearProfileFormMessages() {
    _profileEditErrorMessage = null;
    _profileEditSuccessMessage = null;
  }

  void updateProfileEditMessages(String successMessage, String errorMessage) {
    _profileEditSuccessMessage = successMessage;
    _profileEditErrorMessage = errorMessage;
    notifyListeners();
  }

  void clearProvider() {
    _givenName = null;
    _familyName = null;
    _birthDate = null;
    _job = null;
    _gender = null;
    _email = null;
    _phone = null;
    _street = null;
    _neighborhood = null;
    _city = null;
    _addressDescription = null;
    _photoUrl = null;
    notifyListeners();
  }

  void setUserData({
    String? givenName,
    String? familyName,
    String? birthDate,
    String? job,
    String? gender,
    String? email,
    String? phone,
    String? street,
    String? neighborhood,
    String? photoUrl,
    String? city,
    String? addressDescription,
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
    _photoUrl = photoUrl ?? _photoUrl;

    if (notify) {
      notifyListeners();
    }
  }
}
