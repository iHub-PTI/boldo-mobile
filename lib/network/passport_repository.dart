// get vaccine
import 'dart:convert';
import 'dart:io';

import 'package:boldo/constants.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:open_filex/open_filex.dart' as open;

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
            'profile/caretaker/dependent/${patient.id}/vaccines/vaccinationRegistry/list?all=true&sync=$needSync&groupByDisease=false');
      } else {
        response = await dioPassport.get(
            'profile/patient/vaccines/vaccinationRegistry/list?all=true&sync=$needSync&groupByDisease=false');
      }
      if (response.statusCode == 200) {
        diseaseUserList = userVaccinateFromJson(response.data);
      } else if (response.statusCode == 204) {
        diseaseUserList = [];
      }
      return None();
    } on DioError catch (e) {
      if (e.response!.statusCode == 404) {
        diseaseUserList = [];
        return None();
      }
      await Sentry.captureMessage(
        e.toString(),
        params: [
          {
            "path": e.requestOptions.path,
            "data": e.requestOptions.data,
            "patient": patient.id,
            "responseError": e.response,
          }
        ],
      );
      try{
        throw Failure(e.response?.data['message']);
      }catch (exception ){
        throw Failure(genericError);
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure('Ocurrio un error indesperado');
    }
  }

  Future<None>? downloadVacinnationPdf(bool pdfFromHome) async {
    try {
      print('get user downloadVacinnationPdf');
      final appStorage = await getApplicationDocumentsDirectory();
      var response;
      final file = File(
          '${appStorage.path}/vacunacion_${capitalize(patient.givenName!.split(" ")[0].toLowerCase().toString())}_${capitalize(patient.familyName!.split(" ")[0].toLowerCase().toString())}_${DateFormat('dd-MM-yyy').format(DateTime.now())}.pdf');
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

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      open.OpenFilex.open(file.path);
      return None();
    } on DioError catch (e) {
      await Sentry.captureMessage(
        e.toString(),
        params: [
          {
            "path": e.requestOptions.path,
            "data": e.requestOptions.data,
            "patient": patient.id,
            "responseError": e.response,
          }
        ],
      );
      // try to show backend error message
      try{
        String errorMsg = e.response?.data['message'];
        throw Failure(errorMsg);
      }catch(exception){
        throw Failure(genericError);
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure('Ocurrio un error indesperado');
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
            "profile/caretaker/dependent/${patient.id}/vaccinationRegistry/create?all=$allVaccination",
            data: dataToPass);
      } else {
        response = await dioPassport.post(
            "profile/patient/vaccines/vaccinationRegistry/create?all=$allVaccination",
            data: dataToPass);
      }
      if (response.statusCode == 200) {
        verificationCode = response.data;
      } else if (response.statusCode == 404) {
        throw Failure('Usuario sin registro vacunatorio');
      } else {
        throw Failure('Ocurrió un error inesperado');
      }
    } on DioError catch (e) {
      await Sentry.captureMessage(
        e.toString(),
        params: [
          {
            "path": e.requestOptions.path,
            "data": e.requestOptions.data,
            "patient": patient.id,
            "responseError": e.response,
          }
        ],
      );
      // try to show backend error message
      try{
        String errorMsg = e.response?.data['message'];
        throw Failure(errorMsg);
      }catch(exception){
        throw Failure(genericError);
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure('Ocurrio un error indesperado');
    }
    return verificationCode;
  }
}
