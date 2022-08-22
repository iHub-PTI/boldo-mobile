import 'dart:convert';
import 'dart:io';

import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/main.dart';
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
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

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
      Response response;
      if (prefs.getBool(isFamily) ?? false) {
        response = await dio.get("/profile/caretaker/dependent/${patient.id}/diagnosticReports");
      } else {
        response = await dio.get("/profile/patient/diagnosticReports");
      }
      if (response.statusCode == 200) {
        return List<DiagnosticReport>.from(
            response.data.map((i) => DiagnosticReport.fromJson(i)));
      } else if (response.statusCode == 204) {
        return List<DiagnosticReport>.from([]);
      } else {
        throw Failure(
            "Falló la obtención de los estudios: Error ${response.statusCode}");
      }
    }on DioError catch(ex){
      await Sentry.captureMessage(
        ex.toString(),
        params: [
          {
            "path": ex.requestOptions.path,
            "data": ex.requestOptions.data,
            "patient": prefs.getString("userId"),
            "responseError": ex.response,
          }
        ],
      );
      throw Failure("Falló la obtención de los estudios");
    } catch (e) {
      throw Failure("Falló la obtención de los estudios");
    }
  }

  Future<DiagnosticReport>? getDiagnosticReport(String id) async {
    try {
      Response response;
      if (prefs.getBool(isFamily) ?? false) {
        response = await dio.get("/profile/caretaker/dependent/${patient.id}/diagnosticReport/${id}");
      } else {
        response = await dio.get("/profile/patient/diagnosticReport/$id");
      }
      if (response.statusCode == 200) {
        return DiagnosticReport.fromJson(
            response.data);
      } else if (response.statusCode == 204) {
        throw Failure('El dependiente ya no forma parte de su famila');
      } else {
        throw Failure(
            "Falló la obtención de los estudios: Error ${response.statusCode}");
      }
    }on DioError catch(ex){
      await Sentry.captureMessage(
        ex.toString(),
        params: [
          {
            "path": ex.requestOptions.path,
            "data": ex.requestOptions.data,
            "patient": prefs.getString("userId"),
            "responseError": ex.response,
          }
        ],
      );
      throw Failure("Falló la obtención del estudio");
    } catch (ex) {
      await Sentry.captureMessage(
        ex.toString(),
        params: [
          {
            "patient": prefs.getString("userId"),
          }
        ],
      );
      throw Failure("Falló la obtención del estudio");
    }
  }

  Future<None>? sendDiagnosticReport(DiagnosticReport diagnosticReport ,List<File> files) async {
    try {
      List<Map<String, dynamic>> attachmentUrls = [];
      for (File file in files) {
        // get url to upload file
        Response url = await dio.get("/presigned");
        var response2 = await http.put(Uri.parse(url.data["uploadUrl"]),
            body: file.readAsBytesSync()
        );
        // if file is too large to upload
        if (response2.statusCode == 413) {
          throw Failure(
              'El archivo ${p.basename(file.path)} es demasiado grande');
        } else if (response2.statusCode == 201) {
          var value = {
            "url": url.data["location"],
            "contentType": p.extension(file.path).toLowerCase() == '.pdf'
                ? 'application/pdf'
                : p.extension(file.path).toLowerCase() == '.png' ? 'image/png' : 'image/jpeg',
          };
          attachmentUrls.add(value);
        }
      }
      Map<String, dynamic> diagnostic = diagnosticReport.toJson();
      diagnostic['attachmentUrls'] = attachmentUrls;
      if (prefs.getBool(isFamily) ?? false) {
        await dio.post(
            '/profile/caretaker/dependent/${patient.id}/diagnosticReport',
            data: diagnostic);
      } else {
        await dio.post('/profile/patient/diagnosticReport', data: diagnostic);
      }
      return None();
    } on DioError catch (ex) {
      await Sentry.captureMessage(
        ex.toString(),
        params: [
          {
            "path": ex.requestOptions.path,
            "data": ex.requestOptions.data,
            "patient": patient.id,
            "responseError": ex.response,
          }
        ],
      );
      throw Failure(ex.response?.data['message']);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure('Ocurrio un error indesperado');
    }
  }
}
