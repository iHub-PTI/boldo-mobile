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
  } on DioError catch(exception, stackTrace){
    await Sentry.captureMessage(
      exception.toString(),
      params: [
        {
          "path": exception.requestOptions.path,
          "data": exception.requestOptions.data,
          "patient": prefs.getString("userId"),
          "dependentId": patient.id,
          "responseError": exception.response,
          'access_token': await storage.read(key: 'access_token')
        },
        stackTrace
      ],
    );
    return {
      "errorMessage": "Algo salió mal. Por favor, inténtalo de nuevo más tarde."
    };
  } catch (exception, stackTrace) {
    await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            'patient': prefs.getString("userId"),
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ]
    );
    print(exception);
    return {
      "errorMessage": "Algo salió mal. Por favor, inténtalo de nuevo más tarde."
    };
  }
}
