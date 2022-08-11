// get vaccine
import 'dart:convert';

import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/VaccinationList.dart';

class PassportRepository {
  Future<None>? getUserDiseaseList() async {
    try {
      print('get user Disease List');
      //fake json Covid
      var covidFake = await rootBundle.loadString('assets/fake_jsons/covid_vaccine.json');
      final data = await json.decode(covidFake);
      var covidVaccinate = userVaccinateFromJson(data);

      //fake json Influenza
      var influenzaFake = await rootBundle.loadString('assets/fake_jsons/influenza_vaccine.json');
      final influenzaData = await json.decode(influenzaFake);
      var influenzaVaccinate = userVaccinateFromJson(influenzaData);

      //fake json Varicela
      var varicelaFake = await rootBundle.loadString('assets/fake_jsons/varicela_vaccine.json');
      final varicelaData = await json.decode(varicelaFake);
      var varicelaVaccinate = userVaccinateFromJson(varicelaData);

      diseaseUserList = [influenzaVaccinate,varicelaVaccinate,covidVaccinate];

      return None();

    } catch (e) {
      print(e);
      if (e is DioError) {
        //handle DioError here by error type or by error code

        if (e.error.source != null) {
          throw Failure('${e.error.source}');
        }
      } 
       throw Failure('Error genérico');
    }
  }
}
