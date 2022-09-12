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
    
    try{
      //response = await dio.get('profile/patient/serviceRequest');
      var studiesFake = await rootBundle.loadString('assets/fake_studies_orders/studies_orders.json');
      final data = await json.decode(studiesFake);
      return List<StudyOrder>.from(data.map((i) => StudyOrder.fromJson(i)));
    }catch (e){
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