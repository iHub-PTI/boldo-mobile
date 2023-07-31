import 'dart:io';

import 'package:boldo/main.dart';
import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../constants.dart';
import '../models/DiagnosticReport.dart';
import 'package:path/path.dart' as p;

import 'files_repository.dart';
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
        UploadUrl response = await FilesRepository().getUploadURL();

        await FilesRepository().uploadFile(
          file: file,
          url: response.uploadUrl?? '',
        );
        var value = {
          "url": response.location,
          "contentType": p.extension(file.path).toLowerCase() == '.pdf'
              ? 'application/pdf'
              : p.extension(file.path).toLowerCase() == '.png' ? 'image/png' : 'image/jpeg',
        };
        attachmentUrls.add(value);

      }
      Map<String, dynamic> diagnostic = diagnosticReport.toJson();
      diagnostic['attachmentUrls'] = attachmentUrls;
      Response response;
      if (prefs.getBool(isFamily) ?? false) {
        response = await dio.post(
            '/profile/caretaker/dependent/${patient.id}/diagnosticReport',
            data: diagnostic);
      } else {
        response = await dio.post('/profile/patient/diagnosticReport', data: diagnostic);
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
