import 'dart:convert';

import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
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
}
