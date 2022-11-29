import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Patient.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../network/http.dart';

Future<Map<String, String>> updateProfile(
    {required BuildContext context}) async {
  try {
    print(patient.id);
    if(!(prefs.getBool(isFamily)?? false))
      await dio.post("/profile/patient", data: editingPatient.toJson());
    else
      await dio.put("/profile/caretaker/dependent/${patient.id}", data: editingPatient.toJson());
    BlocProvider.of<PatientBloc>(context).add(ReloadHome());

    patient = Patient.fromJson(editingPatient.toJson());
    if(!(prefs.getBool(isFamily)?? false))
      prefs.setString("profile_url", patient.photoUrl?? '');
    return {"successMessage": "Perfil actualizado con éxito."};
  } on DioError catch (exception, stackTrace) {
    print(exception);
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
    print(exception);
    return {
      "errorMessage": "Algo salió mal. Por favor, inténtalo de nuevo más tarde."
    };
  }
}
