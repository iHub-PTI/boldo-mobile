//Utilities are not project related, they are static and can be imported and moved anywhere.

import 'package:boldo/main.dart';
import 'package:flutter/services.dart';

String? validatePassword(String password) {
  // RegExp hasUpper = RegExp(r'[A-Z]');
  // RegExp hasLower = RegExp(r'[a-z]');
  // RegExp hasDigit = RegExp(r'\d');
  if (password.length < 1) return 'Ingrese un valor primero';
  // if (password.length < 8)
  //   return 'The password must have at least 8 characters';
  // if (!hasUpper.hasMatch(password))
  //   return 'The password must have at least one uppercase character';
  // if (!hasLower.hasMatch(password))
  //   return 'The password must have at least one lowercase character';
  // if (!hasDigit.hasMatch(password))
  //   return 'The password must have at least one number';
   // ignore: null_check_always_fails
  return null;
}

String? validateEmail(String email) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern.toString());
  // email is only for a not dependent
  if (email.isEmpty && !prefs.getBool("isFamily")!) {
    return 'Ingrese su correo electrónico';
  } else if (email.isNotEmpty && !regex.hasMatch(email)) {
    return 'Ingrese un correo electrónico válido';
  } else {
  
    return null;
  }
}

String? valdiateFirstName(String value) {
  if (value.isNotEmpty == false)
    return "First Name is Required";
  else if (value.length > 30)
    return "The First Name is too long";
  else
    return null;
}

String? valdiateLasttName(String value) {
  if (value.isNotEmpty == false)
    return "Last Name is Required";
  else if (value.length > 30)
    return "The Last Name is too long";
  else
    return null;
}

String? validatePasswordConfirmation(String? pass2, String? pass1) {
  return (pass2 == pass1) ? null : "La contraseña no coincide";
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
