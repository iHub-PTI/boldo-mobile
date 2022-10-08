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

  Future<List<Doctor>> getDoctorsFilter(List<Specializations> specializations,
      bool virtualAppointment, bool inPersonAppointment) async {
    try {
      // 173 is the complete list of specializations
      Response response;
      if ( (specializations.isEmpty &&
          !virtualAppointment &&
          !inPersonAppointment) || (specializations.length == 173 &&
          virtualAppointment &&
          inPersonAppointment)) {
        response = await dio.get('/doctors');
        if (response.statusCode == 200) {
          return List<Doctor>.from(
            response.data['items'].map((i) => Doctor.fromJson(i)));
        }
      }
      throw Failure('No se pudo obtener la lista de médicos');
    } catch (e) {
      throw Failure('No se pudo obtener la lista de médicos');
    }
  }

  Future<List<Specializations>>? getAllSpecializations() async {
    try {
      Response response = await dio.get('/specializations');
      if (response.statusCode == 200) {
        return List<Specializations>.from(
            response.data.map((i) => Specializations.fromJson(i)));
      }
      throw Failure('No fue posible obtener las especializaciones');
    } catch (e) {
      throw Failure('No fue posible obtener las especializaciones');
    }
  }
}
