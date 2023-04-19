import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppointmentRepository {

  Future<Appointment?>? getLastAppointment(Doctor doctor) async {

    try{
      Response response;

      response = await dio.get("/profile/patient/lastEncounter/doctors/${doctor.id}",
        queryParameters: {
          "includeDependents": true,
        }
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(response.data);
      }
      return null;
    }on DioError catch(ex) {
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
      throw Failure('No se pudo obtener la ultima consulta');
    }catch (exception, stackTrace){
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }


  }

}