import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:boldo/utils/translate_backend_message.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

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
      } else if(response.statusCode == 204){
        return null;
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    }on DioError catch(exception, stackTrace) {
       captureError(
         exception: exception,
         stackTrace: stackTrace,
       );
      throw Failure('No se pudo obtener la ultima consulta');
    } on Failure catch (exception, stackTrace){
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<None> bookingAppointment({
    required Doctor doctor,
    required NextAvailability bookingDate,
    required OrganizationWithAvailabilities organization,
})async {
    Response response;
    try {
      if(!(prefs.getBool(isFamily)?? false))
        response = await dio.post("/profile/patient/appointments", data: {
          'start': DateTime.parse(bookingDate.availability!)
              .toUtc()
              .toIso8601String(),
          "doctorId": doctor.id,
          "appointmentType": bookingDate.appointmentType,
          "organizationId" : organization.idOrganization
        });
      else
        response = await dio.post("/profile/caretaker/dependent/${patient.id}/appointments", data: {
          'start': DateTime.parse(bookingDate.availability!)
              .toUtc()
              .toIso8601String(),
          "doctorId": doctor.id,
          "appointmentType": bookingDate.appointmentType,
          "organizationId" : organization.idOrganization
        });
      if(response.statusCode == 200) {
        return const None();
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);

    } on DioError catch(exception, stackTrace){

      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(translateBackendMessage(exception.response));
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<List<Appointment>>? getPastAppointments(String date) async {
    Response responseAppointments;
    try {
      if (!(prefs.getBool(isFamily)?? false))
        responseAppointments =
        await dio.get("/profile/patient/appointments",
          queryParameters: {
            "start": date,
          },
        );
      else
        responseAppointments = await dio.get(
            "/profile/caretaker/dependent/${patient.id}/appointments",
          queryParameters: {
            "start": date,
          },
        );

      if (responseAppointments.statusCode == 200) {
        List<Appointment> allAppointmets = List<Appointment>.from(
            responseAppointments.data["appointments"]
                .map((i) => Appointment.fromJson(i)));

        // Past appointment
        allAppointmets = allAppointmets
            .where((element) => ["closed", "locked","open"].contains(element.status))
            .toList();

        allAppointmets.sort((a, b) =>
            DateTime.parse(b.start!).compareTo(DateTime.parse(a.start!)));

        return allAppointmets;
      }

      throw Failure('Unknown StatusCode ${responseAppointments.statusCode}', response: responseAppointments);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener las citas");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<List<Appointment>>? getPastAppointmentsBetweenDates(DateTime? date1, DateTime? date2) async {
    String firstDate = date1!= null? "${DateTime(date1.year, date1.month, date1.day).toUtc().toIso8601String()}" : "${DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String()}";
    String lastDate = date2!= null? "${DateTime(date2.year, date2.month, date2.day).add(const Duration(days: 1)).toUtc().toIso8601String()}" : "";
    Response responseAppointments;
    try {
      if (!(prefs.getBool(isFamily)?? false))
        responseAppointments =
        await dio.get("/profile/patient/appointments",
          queryParameters: {
            "start": firstDate,
            "end": lastDate,
          },
        );
      else
        responseAppointments = await dio.get(
            "/profile/caretaker/dependent/${patient.id}/appointments",
          queryParameters: {
            "start": firstDate,
            "end": lastDate,
          },);

      if (responseAppointments.statusCode == 200) {
        List<Appointment> allAppointmets = List<Appointment>.from(
            responseAppointments.data["appointments"]
                .map((i) => Appointment.fromJson(i)));

        // Past appointment
        allAppointmets = allAppointmets
            .where((element) => ["closed", "locked","open"].contains(element.status))
            .toList();

        allAppointmets.sort((a, b) =>
            DateTime.parse(b.start!).compareTo(DateTime.parse(a.start!)));

        return allAppointmets;
      }

      throw Failure('Unknown StatusCode ${responseAppointments.statusCode}', response: responseAppointments);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener las citas");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<None> cancelAppointment({ required Appointment appointment}) async {
    try{
      final response = await dio.post(
          !(prefs.getBool(isFamily)?? false) ?
          "/profile/patient/appointments/cancel/${appointment.id}"
              : "/profile/caretaker/appointments/cancel/${appointment.id}");
      if (response.statusCode == 200) {
        return const None();
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pudo cancelar la cita");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }


  Future<List<Appointment>>? getAppointments() async {
    Response responseAppointments;
    try {
      if (!(prefs.getBool(isFamily)?? false))
        responseAppointments = await dio.get(
          "/profile/patient/appointments",
          queryParameters: {
            "start": DateTime(DateTime
                .now()
                .year, DateTime
                .now()
                .month, DateTime
                .now()
                .day).toUtc().toIso8601String()
          },
        );
      else
        responseAppointments = await dio.get(
          "/profile/caretaker/dependent/${patient
              .id}/appointments",
          queryParameters: {
            "start": DateTime(DateTime
                .now()
                .year, DateTime
                .now()
                .month, DateTime
                .now()
                .day).toUtc().toIso8601String()
          },
        );

      if (responseAppointments.statusCode == 200) {
        return List<Appointment>.from(
            responseAppointments.data["appointments"]
                .map((i) => Appointment.fromJson(i)));
      } else {
        throw Failure("Status ${responseAppointments.statusCode}");
      }
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener las citas");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      if(exception.response != null){
        throw Failure(exception.message);
      }else {
        throw Failure(genericError);
      }
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  static Future<Appointment?>? getAppointmentByEncounterId({required String encounterId}) async {
    try {
      Response response1;
      if(prefs.getBool(isFamily) ?? false) {
        response1 =
        await dio.get('/profile/caretaker/dependent/${patient.id}/encounters/${encounterId}');
      }else{
        response1 =
        await dio.get('/profile/patient/encounters/${encounterId}');
      }
      if (response1.statusCode == 200) {
        if (response1.data["encounter"]["appointmentId"] != null) {
          String appointmentId = response1.data["encounter"]["appointmentId"];
          Response response2;
          if(prefs.getBool(isFamily) ?? false) {
            response2 =
            await dio.get('/profile/caretaker/dependent/${patient.id}/appointments/${appointmentId}');
          }else{
            response2 =
            await dio.get('/profile/patient/appointments/${appointmentId}');
          }
          if (response2.statusCode == 200) {
            return Appointment.fromJson(response2.data);
          }
          throw Failure('Unknown StatusCode ${response2.statusCode}', response: response2);
        }
      }
      throw Failure('Unknown StatusCode ${response1.statusCode}', response: response1);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure('No fue posible obtener la cita');
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      if(exception.response != null){
        throw Failure(exception.message);
      }else {
        throw Failure(genericError);
      }
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

}