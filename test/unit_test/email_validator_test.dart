import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/utils/form_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  //Initialize Prefrences first with mock value for isFamily, we need check the email
  //only for a not dependent
  SharedPreferences.setMockInitialValues({isFamily: false});
  prefs = await SharedPreferences.getInstance();
  group('General Validation for emails functions', () {
    test('validate for empty email', () async {
      //Arrange & Act
      var result = validateEmail('');
      //Assert
      expect(result, "Ingrese su correo electrónico");
    });

    test('validate for invalid email', () async {
      //Arrange & Act
      var result = validateEmail('safasdfasdf');
      //Assert
      expect(result, "Ingrese un correo electrónico válido");
    });

    test('validate for valid email', () async {
      //Arrange & Act
      var result = validateEmail('boldo@gmail.com');
      //Assert
      expect(result, null);
    });
  });
}
