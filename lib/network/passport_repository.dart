// get vaccine
import 'dart:convert';

import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
}
