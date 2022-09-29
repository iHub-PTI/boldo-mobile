import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class DoctorRepository {
  Future<List<Doctor>>? getAllDoctors() async {
    try {
      Response response = await dio.get('/doctors');
      if (response.statusCode == 200) {
        return List<Doctor>.from(
            response.data['items'].map((i) => Doctor.fromJson(i)));
      }
      throw Failure('No se pudo obtener la lista de médicos');
    } catch (e) {
      throw Failure('No se pudo obtener la lista de médicos');
    }
  }
}
