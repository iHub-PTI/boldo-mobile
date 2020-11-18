//Utilities are not project related, they are static and can be imported and moved anywhere.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String validatePassword(String password) {
  // RegExp hasUpper = RegExp(r'[A-Z]');
  // RegExp hasLower = RegExp(r'[a-z]');
  // RegExp hasDigit = RegExp(r'\d');
  if (password.length < 1) return 'The password must have at least 1 character';
  // if (password.length < 8)
  //   return 'The password must have at least 8 characters';
  // if (!hasUpper.hasMatch(password))
  //   return 'The password must have at least one uppercase character';
  // if (!hasLower.hasMatch(password))
  //   return 'The password must have at least one lowercase character';
  // if (!hasDigit.hasMatch(password))
  //   return 'The password must have at least one number';

  return null;
}

String validateEmail(String email) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (email.isEmpty) {
    return 'The email is required';
  } else if (!regex.hasMatch(email)) {
    return 'Enter a valid email address';
  } else {
    return null;
  }
}

String valdiateFirstName(String value) {
  if (value.isNotEmpty == false)
    return "First Name is Required";
  else if (value.length > 30)
    return "The First Name is too long";
  else
    return null;
}

String valdiateLasttName(String value) {
  if (value.isNotEmpty == false)
    return "Last Name is Required";
  else if (value.length > 30)
    return "The Last Name is too long";
  else
    return null;
}

String validatePasswordConfirmation(String pass2, String pass1) {
  return (pass2 == pass1) ? null : "The two passwords must match";
}

// Phone number formatter
class ValidatorInputFormatter implements TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    for (int i = 0; i < newValue.text.length; i++) {
      if (newValue.text[i] == "-") {
        return oldValue;
      }
      if (newValue.text[i] == '.') {
        return oldValue;
      }
      if (newValue.text[i] == ',') {
        return oldValue;
      }
    }
    return newValue;
  }
}
