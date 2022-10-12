import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
      // list of IDs
      List<String> listOfSpecializations =
          specializations.map((e) => e.id!).toList();
      String appointmentType = "";
      // here set the tipe of appointment
      if (virtualAppointment && inPersonAppointment) {
        appointmentType = "AV";
      } else if (virtualAppointment) {
        appointmentType = "V";
      } else if (inPersonAppointment) {
        appointmentType = "A";
      }
      Response response = await dio.get('/doctors',
        queryParameters: {
          "appointmentType": appointmentType,
          "specialtyIds": listOfSpecializations
        }
      );
      if (response.statusCode == 200) {
        return List<Doctor>.from(response.data['items'].map((i) => Doctor.fromJson(i)));
      }
      throw Failure('No se pudo obtener la lista de médicos');
    } on DioError catch(ex) {
      await Sentry.captureMessage(
        ex.toString(),
        params: [
          {
            "path": ex.requestOptions.path,
            "data": ex.requestOptions.data,
            "patient": prefs.getString("userId"),
            "responseError": ex.response,
          }
        ],
      );
      throw Failure('No se pudo obtener la lista de médicos');
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
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
