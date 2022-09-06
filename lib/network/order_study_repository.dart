import 'dart:convert';

import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

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
}