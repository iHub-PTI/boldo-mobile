import 'dart:convert';
import 'dart:io';

import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class StudiesOrdersRepository {
  Future<List<StudyOrder>>? getStudiesOrders() async {
    Response response;

    try {
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio
            .get('/profile/caretaker/dependent/${patient.id}/serviceRequests');
      } else {
        // the query is made
        response = await dio.get('/profile/patient/serviceRequests');
      }
      // there are study orders
      if (response.statusCode == 200) {
        return studyOrderFromJson(response.data);
      } // no study orders
      else if (response.statusCode == 204) {
        // return empty list
        return List<StudyOrder>.from([]);
      }
      throw Failure(genericError);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
        data: exception.response?.data
      );
      throw Failure("No se pueden obtener las órdenes de estudio");
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

  Future<StudyOrder>? getStudiesOrdersId(String encounter) async {
    Response response;

    try {
      // the query is made
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio.get(
            '/profile/caretaker/dependent/${patient.id}/encounter/${encounter}/serviceRequests');
      } else {
        response = await dio
            .get('/profile/patient/encounter/${encounter}/serviceRequests');
      }
      // there are study orders
      if (response.statusCode == 200) {
        return StudyOrder.fromJson(response.data);
      } // no study orders
      throw Failure(genericError);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pueden obtener las órdenes de estudio");
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

  Future<List<AttachmentUrl>>? sendFiles(List<File> files) async {
    try {
      List<AttachmentUrl> attachmentUrls = [];
      for (File file in files) {
        // get url to upload file
        Response url = await dio.get("/presigned");
        var response2 = await http.put(Uri.parse(url.data["uploadUrl"]),
            body: file.readAsBytesSync());
        // if file is too large to upload
        if (response2.statusCode == 413) {
          throw Failure(
              'El archivo ${p.basename(file.path)} es demasiado grande');
        } else if (response2.statusCode == 201) {
          AttachmentUrl value = AttachmentUrl(
            url: url.data["location"],
            contentType: p.extension(file.path).toLowerCase() == '.pdf'
                ? 'application/pdf'
                : p.extension(file.path).toLowerCase() == '.png'
                    ? 'image/png'
                    : 'image/jpeg',
          );
          attachmentUrls.add(value);
        }
      }
      return attachmentUrls;
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
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

  Future<None>? sendDiagnosticReport(DiagnosticReport diagnosticReport) async {
    try {
      Map<String, dynamic> diagnostic = diagnosticReport.toJson();
      if (prefs.getBool(isFamily) ?? false) {
        await dio.post(
            '/profile/caretaker/dependent/${patient.id}/diagnosticReport',
            data: diagnostic);
      } else {
        await dio.post('/profile/patient/diagnosticReport', data: diagnostic);
      }
      return None();
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
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

  Future<Appointment?>? getAppointment(String encounter) async {
    try {
      Response response1;
      if(prefs.getBool(isFamily) ?? false) {
        response1 =
        await dio.get('/profile/caretaker/dependent/${patient.id}/encounters/${encounter}');
      }else{
        response1 =
        await dio.get('/profile/patient/encounters/${encounter}');
      }
      if (response1.statusCode == 200) {
        if (response1.data["encounter"]["appointmentId"] != null) {
          String appointmentId = response1.data["encounter"]["appointmentId"];
          Response response2;
          if(prefs.getBool(isFamily) ?? false) {
            response2 =
            await dio.get('/profile/caretaker/dependent/${patient.id}/appointments/${appointmentId}');
          }else{
            response2 =
            await dio.get('/profile/patient/appointments/${appointmentId}');
          }
          if (response2.statusCode == 200) {
            return Appointment.fromJson(response2.data);
          }
          await Sentry.captureMessage(
            "Status code unknown",
            params: [
              {
                "path": response2.requestOptions.path,
                "data": response2.data, //ex.requestOptions.data,
                "patient": prefs.getString("userId"),
                'access_token': await storage.read(key: 'access_token')
              }
            ],
          );
          throw Failure('No fue posible obtener la cita');
        }
        await Sentry.captureMessage(
          "Cant get encounter",
          params: [
            {
              "path": response1.requestOptions.path,
              "data": response1.data, //ex.requestOptions.data,
              "patient": prefs.getString("userId"),
              'access_token': await storage.read(key: 'access_token')
            }
          ],
        );
        throw Failure('No fue posible obtener la cita');
      }
      await Sentry.captureMessage(
        "Status code unknown",
        params: [
          {
            "path": response1.requestOptions.path,
            "data": response1.data, //ex.requestOptions.data,
            "patient": prefs.getString("userId"),
            'access_token': await storage.read(key: 'access_token')
          }
        ],
      );
      throw Failure('No fue posible obtener la cita');
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure('No fue posible obtener la cita');
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

  Future<ServiceRequest>? getServiceRequestId(String serviceRequestId) async {
    Response response;

    try {
      // the query is made
      if(prefs.getBool(isFamily) ?? false) {
        response =
        await dio.get('/profile/caretaker/dependent/${patient.id}/serviceRequest/${serviceRequestId}');
      }else{
        response =
        await dio.get('/profile/patient/serviceRequest/${serviceRequestId}');
      }
      // there are study orders
      if (response.statusCode == 200) {
        return ServiceRequest.fromJson(response.data);
      } // no study orders
      await Sentry.captureMessage(
        "Status code unknown",
        params: [
          {
            "path": response.requestOptions.path,
            "data": response.data, //ex.requestOptions.data,
            "patient": prefs.getString("userId"),
            'access_token': await storage.read(key: 'access_token')
          }
        ],
      );
      throw Failure(genericError);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pueden obtener la orden de estudio");
    }on Failure catch (exception, stackTrace) {
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
