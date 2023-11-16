import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/utils/errors.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    captureError(
      exception: exception,
      stackTrace: stackTrace,
    );
    return {
      "errorMessage": "Algo salió mal. Por favor, inténtalo de nuevo más tarde."
    };
  } on Exception catch (exception, stackTrace) {
    captureError(
      exception: exception,
      stackTrace: stackTrace,
    );
    print(exception);
    return {
      "errorMessage": "Algo salió mal. Por favor, inténtalo de nuevo más tarde."
    };
  }
}
