import 'dart:convert';
import 'dart:io';

import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import '../constants.dart';
import '../models/DiagnosticReport.dart';
import '../screens/my_studies/bloc/my_studies_bloc.dart';

import 'http.dart';

class MyStudesRepository {
  Future<List<String>>? getPatientStudies() async {
    try {
      List<String> estudiosPrueba = [];

      estudiosPrueba.add("Estudio 1");
      estudiosPrueba.add("Estudio 2");
      estudiosPrueba.add("Estudio 3");

      return estudiosPrueba;
      //await Future.delayed(const Duration(seconds: 2));
      //throw Failure('NO se pudo obtener los datos');
      // return None();
      //TODO: agregar endpoint para obtener la lista de estudios
      // Response response = await dio.get("/profile/patient/diagnosticReports");
      // if (response.statusCode == 200) {
      //   // return List<Patient>.from(
      //   //     response.data.map((i) => Patient.fromJson(i)));
      // } else if (response.statusCode == 204) {
      //   return List<Patient>.from([]);
      // }
      // throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<List<DiagnosticReport>>? getDiagnosticReports() async {
    try {
      Response response = await dio.get("/profile/patient/diagnosticReports");
      if (response.statusCode == 200) {
        return List<DiagnosticReport>.from(
            response.data.map((i) => DiagnosticReport.fromJson(i)));
      } else if (response.statusCode == 204) {
        return List<DiagnosticReport>.from([]);
      } else {
        throw Failure(
            "Falló la obtención de los estudios: Error ${response.statusCode}");
      }
    } catch (e) {
      throw Failure(e.toString());
    }
  }
}
