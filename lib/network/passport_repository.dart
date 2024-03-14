// get vaccine
import 'dart:io';

import 'package:boldo/constants.dart';
import 'package:boldo/network/files_repository.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:boldo/utils/files_helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../models/UserVaccinate.dart';

class PassportRepository {
  Future<None>? getUserDiseaseList(bool needSync) async {
    try {
      print('get user Disease List');
      //fake json Covid
      Response response;
      if (prefs.getBool(isFamily) ?? false) {
        response = await dioPassport.get(
            'profile/caretaker/dependent/${patient.id}/vaccines/vaccinationRegistry/list',
          queryParameters: {
            "all": true,
            "sync": needSync,
            "groupByDisease": false,
          },
        );
      } else {
        response = await dioPassport.get(
            'profile/patient/vaccines/vaccinationRegistry/list',
          queryParameters: {
            "all": true,
            "sync": needSync,
            "groupByDisease": false,
          },
        );
      }
      if (response.statusCode == 200) {
        diseaseUserList = userVaccinateFromJson(response.data);
      } else if (response.statusCode == 204) {
        diseaseUserList = [];
      }
      return None();
    } on DioError catch (exception, stackTrace) {
      if (exception.response!.statusCode == 404) {
        diseaseUserList = [];
        return None();
      }else {
        captureError(
          exception: exception,
          stackTrace: stackTrace,
        );
      }
      throw Failure(genericError);
    } on Failure catch (exception, stackTrace){
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace){
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

  Future<None>? downloadVacinnationPdf(bool pdfFromHome) async {
    try {
      print('get user downloadVacinnationPdf');
      final appStorage = await getApplicationDocumentsDirectory();
      Response response;
      List<String> diseaseCode = [];
      List<UserVaccinate>? vaccine = [];
      if (pdfFromHome == true) {
        vaccine = diseaseUserList;
      } else if (pdfFromHome == false) {
        vaccine = vaccineListQR;
      }

      // in this case the path is easier
      if (vaccine!.length == diseaseUserList!.length) {
        if (prefs.getBool(isFamily) ?? false) {
          response = await dioDownloader.get(
              'profile/caretaker/dependent/${patient.id}/vaccines/vaccinationRegistry/list/pdf',
              queryParameters: {"all": true});
        } else {
          response = await dioDownloader.get(
              'profile/patient/vaccines/vaccinationRegistry/list/pdf',
              queryParameters: {"all": true});
        }
      } else {
        //and this case the path for query required a query param
        for (var i = 0; i < vaccine.length; i++) {
          // and then, add all elements
          diseaseCode.add(vaccine[i].diseaseCode);
        }
        if (prefs.getBool(isFamily) ?? false) {
          response = await dioDownloader.get(
              'profile/caretaker/dependent/${patient.id}/vaccines/vaccinationRegistry/list/pdf',
              queryParameters: {"diseaseCode": diseaseCode});
        } else {
          response = await dioDownloader.get(
              'profile/patient/vaccines/vaccinationRegistry/list/pdf',
              queryParameters: {"diseaseCode": diseaseCode});
        }
      }

      String? filename = FilesRepository.getFilename(
        headers: response.headers,
      );

      FilesHelpers.openFile(
        file: response.data,
        fileName: filename,
        extension: '.pdf',
      );
      return None();
    } on DioError catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } on Failure catch (exception, stackTrace){
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace){
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

  Future<String>? postVerificationCode(
      bool allVaccination, dynamic dataToPass) async {
    String verificationCode;
    try {
      print("post verification code");
      Response response;
      if (prefs.getBool(isFamily) ?? false) {
        response = await dioPassport.post(
            "profile/caretaker/dependent/${patient.id}/vaccinationRegistry/create",
            queryParameters: {
              "all": allVaccination,
            },
            data: dataToPass);
      } else {
        response = await dioPassport.post(
            "profile/patient/vaccines/vaccinationRegistry/create",
            queryParameters: {
              "all": allVaccination,
            },
            data: dataToPass);
      }
      if (response.statusCode == 200) {
        verificationCode = response.data;
        return verificationCode;
      } else if (response.statusCode == 404) {
        throw Failure('Usuario sin registro vacunatorio');
      } else {
        throw Failure('Ocurrió un error inesperado');
      }
    } on DioError catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } on Failure catch (exception, stackTrace){
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace){
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
}
