import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dio/dio.dart';
import '../constants.dart';
import 'http.dart';

class UserRepository {
  Future<Patient>? getPatient() async {
    try {
      Response response = await dio.get("/profile/patient");
      if(response.statusCode == 200){
        return Patient.fromJson(response.data);
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }
}