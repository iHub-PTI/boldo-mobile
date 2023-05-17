import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DoctorRepository {
  Future<List<Doctor>>? getAllDoctors(int offset) async {
    try {
      Response response;
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio.get('/profile/caretaker/dependent/${patient.id}/doctors',
            queryParameters: {
              "offset": offset,
              "count": offset + 20
            }
        );
      } else {
        // the query is made
        response = await dio.get('/profile/patient/doctors',
            queryParameters: {
              "offset": offset,
              "count": offset + 20
            }
        );
      }
      if (response.statusCode == 200) {
        return List<Doctor>.from(
            response.data['items'].map((i) => Doctor.fromJson(i)));
      }
      throw Failure('No se pudo obtener la lista de médicos');
    } catch (e) {
      throw Failure('No se pudo obtener la lista de médicos');
    }
  }

  Future<List<Doctor>> getDoctorsFilter(
      int offset,
      List<Specializations> specializations,
      bool virtualAppointment,
      bool inPersonAppointment,
      List<Organization> organizations,
      List<String> names,
      ) async {
    try {
      // list of IDs
      List<String> listOfSpecializations =
          specializations.map((e) => e.id!).toList();

      // list of names split for spaces
      String listOfNames = names.join(" ");

      // list of organizations IDs
      String listOfOrganizations =
      organizations.map((e) => e.id!).toList().join(",");

      String? appointmentType;
      // here set the type of appointment
      if (virtualAppointment && inPersonAppointment) {
        appointmentType = "AV";
      } else if (virtualAppointment) {
        appointmentType = "V";
      } else if (inPersonAppointment) {
        appointmentType = "A";
      }
      dynamic queryParams = {
        "appointmentType": appointmentType,
        "specialtyIds": listOfSpecializations,
        "offset": offset,
        "count": offset + 20,
        "organizations": listOfOrganizations == ""? null : listOfOrganizations,
        "names": listOfNames.split(" "),
      };

      // remove null values to solve null compare in server
      queryParams.removeWhere((key, value) => value == null);

      Response response;
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio.get('/profile/caretaker/dependent/${patient.id}/doctors',
            queryParameters: queryParams
        );
      } else {
        // the query is made
        response = await dio.get('/profile/patient/doctors',
            queryParameters: queryParams
        );
      }
      if (response.statusCode == 200) {
        List<Doctor> doctors = List<Doctor>.from(response.data['items'].map((i) => Doctor.fromJson(i)));
        return doctors;
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

  Future<List<Doctor>> getRecentDoctors(
      int offset,
      List<Specializations> specializations,
      bool virtualAppointment,
      bool inPersonAppointment,
      List<Organization> organizations,
      List<String> names,
      ) async {
    try {
      // list of IDs
      List<String> listOfSpecializations =
      specializations.map((e) => e.id!).toList();

      // list of names split for spaces
      String listOfNames = names.join(" ");

      // list of organizations IDs
      String listOfOrganizations =
      organizations.map((e) => e.id!).toList().join(",");

      String? appointmentType;
      // here set the type of appointment
      if (virtualAppointment && inPersonAppointment) {
        appointmentType = "AV";
      } else if (virtualAppointment) {
        appointmentType = "V";
      } else if (inPersonAppointment) {
        appointmentType = "A";
      }
      dynamic queryParams = {
        "appointmentType": appointmentType,
        "specialtyIds": listOfSpecializations,
        "offset": offset,
        "count": offset + 20,
        "organizations": listOfOrganizations == ""? null : listOfOrganizations,
        "names": listOfNames.split(" "),
      };

      // remove null values to solve null compare in server
      queryParams.removeWhere((key, value) => value == null);

      Response response;
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio.get('/profile/caretaker/dependent/${patient.id}/recent/doctors',
            queryParameters: queryParams
        );
      } else {
        // the query is made
        response = await dio.get('/profile/patient/recent/doctors',
            queryParameters: queryParams
        );
      }
      if (response.statusCode == 200) {
        List<Doctor> doctors = List<Doctor>.from(response.data.map((i) => Doctor.fromJson(i)));
        return doctors;
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

  Future<None> putFavoriteStatus(
      Doctor doctor,
      bool favoriteStatus
      ) async {
    try {
      dynamic queryParams = {
        "addFavorite": favoriteStatus,
      };

      // remove null values to solve null compare in server
      queryParams.removeWhere((key, value) => value == null);

      Response response;
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio.get('/profile/caretaker/dependent/${patient.id}/favorite/doctor/${doctor.id}',
            queryParameters: queryParams
        );
      } else {
        // the query is made
        response = await dio.put('/profile/patient/favorite/doctor/${doctor.id}',
            queryParameters: queryParams
        );
      }
      return const None();
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
      print(ex.response?.data);
      throw Failure('No se establecer como favorito');
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

}
