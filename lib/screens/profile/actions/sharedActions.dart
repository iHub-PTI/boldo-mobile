import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../provider/user_provider.dart';
import '../../../network/http.dart';

Future<Map<String, String>> updateProfile(
    {required BuildContext context}) async {
  try {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    await dio.post("/profile/patient", data: {
      "givenName": userProvider.getGivenName,
      "familyName": userProvider.getFamilyName,
      "birthDate": userProvider.getBirthDate,
      "job": userProvider.getJob,
      "gender": userProvider.getGender,
      "email": userProvider.getEmail,
      "phone": userProvider.getPhone,
      "photoUrl": userProvider.getPhotoUrl,
      "street": userProvider.getStreet,
      "neighborhood": userProvider.getNeighborhood,
      "city": userProvider.getCity,
      "addressDescription": userProvider.getAddressDescription,
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_url", userProvider.getPhotoUrl);
    await prefs.setString("gender", userProvider.getGender);

    return {"successMessage": "Perfil actualizado con éxito."};
  } on DioError catch (exception, stackTrace) {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
    return {
      "errorMessage": "Algo salió mal. Por favor, inténtalo de nuevo más tarde."
    };
  } catch (exception, stackTrace) {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
    return {
      "errorMessage": "Algo salió mal. Por favor, inténtalo de nuevo más tarde."
    };
  }
}
