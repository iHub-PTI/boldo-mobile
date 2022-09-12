import 'dart:convert';
import 'dart:io';

import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sentry_flutter/sentry_flutter.dart';

class StudiesOrdersRepository {
  Future<List<StudyOrder>>? getStudiesOrders() async {
    Response response;

    try {
      // the query is made
      response = await dio.get('/profile/patient/serviceRequests');
      // there are study orders
      if (response.statusCode == 200) {
        return studyOrderFromJson(response.data);
      } // no study orders
      else if (response.statusCode == 204) {
        // return empty list
        return List<StudyOrder>.from([]);
      }
      throw Failure(genericError);
    } on DioError catch(ex){
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
      throw Failure("No se pueden obtener las órdenes de estudio");
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  Future<List<StudyOrder>>? getStudiesOrdersId(String encounter) async {
    Response response;

    try {
      // the query is made
      response = await dio.get('/profile/patient/encounter/${encounter}/serviceRequests');
      // there are study orders
      if (response.statusCode == 200) {
        return studyOrderFromJson(response.data);
      } // no study orders
      else if (response.statusCode == 204) {
        // return empty list
        return List<StudyOrder>.from([]);
      }
      throw Failure(genericError);
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
      throw Failure("No se pueden obtener las órdenes de estudio");
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  Future<List<AttachmentUrl>>? sendFiles(List<File> files) async {
    try {
      List<AttachmentUrl> attachmentUrls = [];
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
          AttachmentUrl value = AttachmentUrl(
            url: url.data["location"],
            contentType: p.extension(file.path).toLowerCase() == '.pdf'
                ? 'application/pdf'
                : p.extension(file.path).toLowerCase() == '.png' ? 'image/png' : 'image/jpeg',
          );
          attachmentUrls.add(value);
        }
      }
      return attachmentUrls;
      } on DioError catch(ex){
      throw Failure(ex.response?.data['message']);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure('Ocurrio un error indesperado');
    }
  }

  Future<None>? sendDiagnosticReport(DiagnosticReport diagnosticReport) async {
    try{
      Map<String, dynamic> diagnostic = diagnosticReport.toJson();
      if (prefs.getBool(isFamily) ?? false) {
        await dio.post(
            '/profile/caretaker/dependent/${patient.id}/diagnosticReport',
            data: diagnostic);
      } else {
        await dio.post('/profile/patient/diagnosticReport', data: diagnostic);
      }
      return None();
    }on DioError catch (ex) {
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
