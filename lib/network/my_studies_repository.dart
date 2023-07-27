import 'dart:convert';
import 'dart:io';

import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/DiagnosticReport.dart';
import 'package:path/path.dart' as p;

import 'http.dart';

class MyStudesRepository {

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
        throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
      }
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("Falló la obtención de los estudios");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
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
        throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
      }
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("Falló la obtención del estudio");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
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
        }else{
          throw Failure('Unknown StatusCode ${url.statusCode}', response: url);
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
      if(response.statusCode == 201){
        return const None();
      }else if(response.statusCode == 204){
        throw Failure ("No se pudo subir el estudio");
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pudo subir el estudio");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      if(exception.response != null){
        throw Failure(exception.message);
      }else {
        throw Failure(genericError);
      }
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }
}
