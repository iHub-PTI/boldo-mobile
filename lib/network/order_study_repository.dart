import 'dart:io';
import 'dart:typed_data';

import 'package:boldo/constants.dart';
import 'package:boldo/environment.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'files_repository.dart';

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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
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
    } catch (exception, stackTrace) {
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
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
    } catch (exception, stackTrace) {
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
        UploadUrl response = await FilesRepository().getUploadURL();

        await FilesRepository().uploadFile(
          file: file,
          url: response.uploadUrl?? '',
        );

        AttachmentUrl value = AttachmentUrl(
          url: response.location,
          contentType: p.extension(file.path).toLowerCase() == '.pdf'
              ? 'application/pdf'
              : p.extension(file.path).toLowerCase() == '.png'
                  ? 'image/png'
                  : 'image/jpeg',
        );
        attachmentUrls.add(value);

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
    } catch (exception, stackTrace) {
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
        throw Failure("No se pudo subir el estudio");
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
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
    } catch (exception, stackTrace) {
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
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
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  static Future<Uint8List> downloadStudiesOrders ({
    required List<String?> studiesOrdersId,
  }) async {
    try {

      String url;

      // remove null ids
      Map<String, dynamic> queryParams ={
        'id': studiesOrdersId.where((element) => element != null),
      };

      // declare a connection to download with access token and urlBase
      Dio _dioDownloader = Dio();
      initDio(navKey: navKey, dio: _dioDownloader, baseUrl: environment.SERVER_ADDRESS, responseType: ResponseType.bytes);

      // the query is made
      if(prefs.getBool(isFamily) ?? false) {
        url = '/profile/caretaker/dependent/${patient.id}/serviceRequests/reports/';
      }else{
        url = '/profile/patient/serviceRequests/reports';
      }
      Uint8List file = await FilesRepository.getFile(
        localDio: _dioDownloader,
        queryParams: queryParams,
        url: url,
      );
      return file;
    } on Failure catch (exception, stackTrace){
      throw exception;
    }catch (exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

}
