// get vaccine
import 'dart:convert';
import 'dart:io';

import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:open_file/open_file.dart' as open;

import '../main.dart';
import '../models/UserVaccinate.dart';

class PassportRepository {
  Future<None>? getUserDiseaseList(bool needSync) async {
    try {
      print('get user Disease List');
      //fake json Covid
      Response response = await dioPassport.get(
          '/profile/citizen/vaccinationRegistry/list?all=true&sync=$needSync&groupByDisease=false');
      if (response.statusCode == 200) {
        diseaseUserList = userVaccinateFromJson(response.data);
      }
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
      throw Failure(e.response?.data['message']);
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
        //vaccine = vaccineListQR;
      }

      // in this case the path is easier
      if (vaccine!.length == diseaseUserList!.length) {
        response = await dioDownloader.get(
            'profile/citizen/vaccinationRegistry/list/pdf',
            queryParameters: {"all": true});
      } else {
        //and this case the path for query required a query param
        for (var i = 0; i < vaccine.length; i++) {
          // and then, add all elements
          diseaseCode.add(vaccine[i].diseaseCode);
        }
        response = await dioDownloader.get(
            'profile/citizen/vaccinationRegistry/list/pdf',
            queryParameters: {"diseaseCode": diseaseCode});
      }

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      open.OpenFile.open(file.path);
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
      throw Failure(e.response?.data['message']);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure('Ocurrio un error indesperado');
    }
  }
}
