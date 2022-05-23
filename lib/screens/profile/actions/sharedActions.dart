import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/main.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    await dio.post("/profile/patient", data: patient.toJson());

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_url", userProvider.getPhotoUrl??'');
    await prefs.setString("gender", userProvider.getGender??'');
    BlocProvider.of<PatientBloc>(context).add(ReloadHome());

    if(!prefs.getBool("isFamily")!)
      prefs.setString("profile_url", patient.photoUrl?? '');

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
