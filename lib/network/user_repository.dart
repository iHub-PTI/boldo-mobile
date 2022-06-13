import 'dart:convert';
import 'dart:io';

import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/Relationship.dart';
import 'package:boldo/models/User.dart';
import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import '../constants.dart';
import '../main.dart';
import '../models/Appointment.dart';
import '../models/Doctor.dart';
import 'http.dart';

class UserRepository {
  final List<String> errorInFrontSide = [
    "The front of the IdCardParaguay card could not be validated",
    "Invalid name",
    "Invalid last name",
    "Invalid sex",
    "Invalid birthDate",
  ];

  final List<String> errorInBackSide = [
    "The back of the IdCardParaguay card could not be validated",
    "Invalid IC",
    "Invalid Document number",
    "Invalid nationality",
  ];

  final List<String> errorInSelfie = [
    "Face could not be validated",
  ];

  final List<String> patientAndDependentAreTheSameErrors = [
    'The dependent and the caretaker are the same'
  ];

  final List<String> relationshipWithDependentAlreadyExistErrors = [
    'Relationship of dependence with the patient is already exists'
  ];

  Future<None>? getPatient(String? id) async {
    try {
      Response response = id == null
          ? await dio.get("/profile/patient")
          : await dio.get("/profile/caretaker/dependent/$id");
      if (response.statusCode == 200) {
        patient = Patient.fromJson(response.data);
        return const None();
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure("No se puede obtener el usuario");
    }
  }

  Future<None>? getDependents() async {
    try {
      Response response = await dio.get("/profile/caretaker/dependents");
      print(response.data);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.data.map((i) => Patient.fromJson(i)));
        families =
            List<Patient>.from(response.data.map((i) => Patient.fromJson(i)));
        return const None();
      } else if (response.statusCode == 204) {
        families = List<Patient>.from([]);
        return const None();
      }
      families = List<Patient>.from([]);
      throw Failure(genericError);
    } catch (e) {
      print(e);
      families = List<Patient>.from([]);
      throw Failure(genericError);
    }
  }

  Future<List<Patient>>? getManagements() async {
    try {
      Response response = await dio.get("/profile/patient/caretaker");
      if (response.statusCode == 200) {
        return List<Patient>.from(
            response.data.map((i) => Patient.fromJson(i)));
      } else if (response.statusCode == 204) {
        return List<Patient>.from([]);
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? getDependent(String id) async {
    print("ID $id");
    try {
      Response response =
          await dio.get("/profile/caretaker/dependent/confirm/$id");
      if (response.statusCode == 200) {
        print(response.data);
        user = User.fromJson(response.data);
        return const None();
      }
      print(response.statusCode);
      throw Failure(genericError);
    } catch (e) {
      print("ERROR $e inesperado");
      throw Failure(genericError);
    }
  }

  Future<List<MedicalRecord>> getMedicalRecords() async {
    Response response = await dioHealthCore.get(
        "/profile/patient/relatedEncounters?includePrescriptions=false&includeSoep=false&lastOnly=true");
    late List<MedicalRecord> list;
    try {
      list = List<MedicalRecord>.from(
          response.data.map((x) => MedicalRecord.fromJson(x[0])));
    } catch (e) {
      print("ERROR $e");
    }
    print("GETTED");
    return list;
  }

  Future<None>? getRelationships() async {
    try {
      Response response = await dio.get("/profile/caretaker/relationships");
      if (response.statusCode == 200) {
        print(response.data);
        relationTypes = List<Relationship>.from(
            response.data.map((i) => Relationship.fromJson(i)));
        return const None();
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? setDependent(bool isNew) async {
    try {
      var data = isNew ? user.toJsonNewPatient() : user.toJsonExistPatient();
      print(data);
      Response response =
      await dio.post("/profile/caretaker/dependent", data: data);
      if (response.statusCode == 200) {
        return const None();
      }
      throw Failure(genericError);
    }on DioError catch (ex){
      print(ex);
      if(patientAndDependentAreTheSameErrors.contains(ex.response?.data['messages'].join())){
        throw Failure("El familiar no puede ser el mismo que el principal");
      }else if(relationshipWithDependentAlreadyExistErrors.contains(ex.response?.data['messages'].join())){
        throw Failure("El familiar ya se encuentra asignado");
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? unlinkDependent(String id) async {
    try {
      Response response =
          await dio.put("/profile/caretaker/inactivate/dependent/$id");
      if (response.statusCode == 200) {
        return const None();
      } else if (response.statusCode == 204) {
        throw Failure("El familiar ya fue borrado con anterioridad");
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<List<NextAvailability>>? getAvailabilities({required String id, required String startDate, required String endDate}) async {
    try {
      Response response = await dio
          .get("/doctors/$id/availability", queryParameters: {
        'start': startDate,
        'end': endDate,
      });
      if (response.statusCode == 200) {
        List<NextAvailability>? allAvailabilities = [];
        response.data['availabilities'].forEach((v) {
          allAvailabilities.add(NextAvailability.fromJson(v));
        });
        for ( NextAvailability availability in allAvailabilities){
          availability.availability = DateTime.parse(availability.availability!).toLocal().toString();
        }
        return allAvailabilities;
      } else if (response.statusCode == 204) {
        throw Failure("El familiar ya fue borrado con anterioridad");
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? sendUserPreliminaryProfile(BuildContext context) async {
    try {
      final String cellPhone = user.phone!;
      Response response =
          await dio.post("/preRegister/sedCode?cellphone=%2B$cellPhone");
      if (response.statusCode == 201) {
        return const None();
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? getUrlFromServer(UrlUploadType urlUploadType) async {
    try {
      print('getUrlFromServer');
      String? isLogged = await storage.read(key: "access_token");
      final hash = await storage.read(key: "hash");
      print("hash $hash");
      String url = "";
      switch (urlUploadType) {
        case UrlUploadType.frontal:
          url = isLogged == null
              ? "/preRegister/s3/validateDocument/idCardParaguay/side1/uploadPresigned?hash=$hash"
              : "/profile/caretaker/dependent/s3/validateDocument/idCardParaguay/side1/uploadPresigned";
          break;
        case UrlUploadType.back:
          url = isLogged == null
              ? "/preRegister/s3/validateDocument/idCardParaguay/side2/uploadPresigned?hash=$hash"
              : "/profile/caretaker/dependent/s3/validateDocument/idCardParaguay/side2/uploadPresigned?hash=$hash";
          break;
        case UrlUploadType.selfie:
          url = isLogged == null
              ? "/preRegister/s4/validateSelfie/uploadPresigned?hash=$hash"
              : "/profile/caretaker/dependent/s4/validateSelfie/uploadPresigned?hash=$hash";
          break;
        default:
      }
      Response response = await dio.get(url);
      print("url $url");
      print("response ${response.data} from url=$url");
      if (response.statusCode == 200) {
        switch (urlUploadType) {
          case UrlUploadType.frontal:
            frontDniUrl = uploadUrlFromJson(response.data);
            print("${frontDniUrl.hash} url=${frontDniUrl.uploadUrl}");
            await storage.write(key: "hash", value: frontDniUrl.hash);
            print("hash frontal ${frontDniUrl.hash}");
            break;
          case UrlUploadType.back:
            backDniUrl = uploadUrlFromJson(response.data);
            break;
          case UrlUploadType.selfie:
            userSelfieUrl = uploadUrlFromJson(response.data);
            break;
          default:
        }

        return const None();
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? validateUserPhone(String hash, BuildContext context) async {
    try {
      final String phone = user.phone!;
      //final String password = user.password!;
      Response response =
          await dio.post("preRegister/validateCode?hash=$hash&phone=$phone");
      if (response.statusCode == 200) {
        return const None();
      }
      throw Failure('No fue posible validad el número, intente nuevamente');
    } catch (e) {
      throw Failure('No fue posible validad el número, intente nuevamente');
    }
  }

  Future<None>? sendImagetoServer(
      UrlUploadType urlUploadType, XFile image) async {
    try {
      print("send image to server");
      String url = "";
      switch (urlUploadType) {
        case UrlUploadType.frontal:
          url = frontDniUrl.uploadUrl!;
          break;
        case UrlUploadType.back:
          url = backDniUrl.uploadUrl!;
          break;
        case UrlUploadType.selfie:
          url = userSelfieUrl.uploadUrl!;
          break;
        default:
      }
      final file = File(image.path);

      final _dio = Dio();
      final fileBytes = file.readAsBytesSync();
      var streamData = Stream.fromIterable(fileBytes.map((e) => [e]));

      final response = await _dio.put(url,
          data: streamData,
          options: Options(headers: {
            Headers.contentLengthHeader: fileBytes.length,
            "x-ms-blob-type": "BlockBlob",
            "content-type": "image/jpeg"
          }));
      print('image sending');

      if (response.statusCode == 201) {
        //if uploaded successfully, this services check if data in DNI match with user
        print('succefully sended');
        String? isLogged = await storage.read(key: "access_token");
        final hash = await storage.read(key: "hash");
        String _url = "";
        switch (urlUploadType) {
          case UrlUploadType.frontal:
            _url = isLogged == null
                ? "/preRegister/s3/validateDocument/idCardParaguay/side1/validate?hash=$hash"
                : "/profile/caretaker/dependent/s3/validateDocument/idCardParaguay/side1/validate?hash=$hash";
            break;
          case UrlUploadType.back:
            _url = isLogged == null
                ? "/preRegister/s3/validateDocument/idCardParaguay/side2/validate?hash=$hash"
                : "/profile/caretaker/dependent/s3/validateDocument/idCardParaguay/side2/validate?hash=$hash";
            break;
          case UrlUploadType.selfie:
            _url = isLogged == null
                ? "/preRegister/s4/validateSelfie/validate?hash=$hash"
                : "/profile/caretaker/dependent/s4/validateSelfie/validate?hash=$hash";
            break;
          default:
        }
        final _finalUrl =
            '${String.fromEnvironment('SERVER_ADDRESS', defaultValue: dotenv.env['SERVER_ADDRESS']!)}$_url';
        print(_finalUrl);
        var response = await dio.post(_finalUrl);
        print(response.statusCode);
        if (response.statusCode == 200) {
          print(response.data);
          if (urlUploadType == UrlUploadType.selfie && isLogged != null) {
            user = User.fromJson(response.data);
          }
          photoStage == UrlUploadType.frontal
              ? photoStage = UrlUploadType.back
              : photoStage = UrlUploadType.selfie;
          return const None();
        } else {
          print(response.data);
          return throw Failure(response.data);
        }
      }
      throw Failure(genericError);
    } on DioError catch (ex) {
      if (errorInFrontSide.contains(ex.response?.data['messages'].join())) {
        photoStage = UrlUploadType.frontal;
        throw Failure("Error al validar la parte frontal");
      } else if (errorInBackSide
          .contains(ex.response?.data['messages'].join())) {
        photoStage = UrlUploadType.back;
        throw Failure("Error al validar la parte posterior");
      } else if (errorInSelfie.contains(ex.response?.data['messages'].join())) {
        photoStage = UrlUploadType.selfie;
        throw Failure("Error al validar la selfie");
      }
      throw Failure(genericError);
    } catch (e) {
      print(e);
      throw Failure('${e.toString().length > 60 ? '$genericError' : e}');
    }
  }

  Future<None>? sendUserPassword() async {
    try {
      final hash = await storage.read(key: "hash");
      final String password = user.password!;
      Response response = await dio
          .post("preRegister/s5/registerUser?hash=$hash&pass=$password");
      if (response.statusCode == 201) {
        return const None();
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  void logout(BuildContext context) async {
    try {
      String baseUrlKeyCloack = String.fromEnvironment('KEYCLOAK_REALM_ADDRESS',
          defaultValue: dotenv.env['KEYCLOAK_REALM_ADDRESS']!);

      String? refreshToken = await storage.read(key: "refresh_token");
      Map<String, dynamic> body = {
        "refresh_token": refreshToken ?? '',
        "client_id": "boldo-patient"
      };
      var url = Uri.parse("$baseUrlKeyCloack/protocol/openid-connect/logout");
      await http.post(url,
          body: body,
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          encoding: Encoding.getByName("utf-8"));
      await prefs.setBool("onboardingCompleted", false);
      await storage.deleteAll();
      await prefs.clear();
      patient = Patient();

      Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding', (Route<dynamic> route) => false);
    } on DioError catch (exception, stackTrace) {
      print(exception);

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<NextAvailability>>? getDoctorAvailability(
      Doctor doctor, DateTime date) async {
    try {
      Response response =
          await dio.get("/doctors/${doctor.id}/availability", queryParameters: {
        'start': date.toUtc().toIso8601String(),
        'end': DateTime(date.year, date.month + 1, 1).toUtc().toIso8601String(),
      });
      List<NextAvailability>? allAvailabilities = [];
      if (response.statusCode == 200) {
        return response.data['availabilities'].forEach((v) {
          allAvailabilities.add(NextAvailability.fromJson(v));
        });
      } else if (response.statusCode == 204) {
        return [];
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<Doctor>? getDoctor({required String id}) async {
    try {
      Response response = await dio
          .get("/doctors/$id");
      if (response.statusCode == 200) {
        return Doctor.fromJson(response.data);
      } else if (response.statusCode == 204) {
        throw Failure("Doctor no encontrado");
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<List<Appointment>>? getPastAppointments(String date) async {
    Response responseAppointments;
    try {
      if (!prefs.getBool(isFamily)!)
        responseAppointments =
            await dio.get("/profile/patient/appointments?start=$date");
      else
        responseAppointments = await dio.get(
            "/profile/caretaker/dependent/${patient.id}/appointments?start=$date");

      if (responseAppointments.statusCode == 200) {
        List<Appointment> allAppointmets = List<Appointment>.from(
            responseAppointments.data["appointments"]
                .map((i) => Appointment.fromJson(i)));

        // Past appointment
        allAppointmets = allAppointmets
            .where((element) => ["closed", "locked"].contains(element.status))
            .toList();

        allAppointmets.sort((a, b) =>
            DateTime.parse(b.start!).compareTo(DateTime.parse(a.start!)));

        return allAppointmets;
      }

      throw Failure("Status deconocido ${responseAppointments.statusCode}");
    } on DioError catch (exception, stackTrace) {
      print(exception);

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      print(exception);

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<MedicalRecord>? getMedicalRecordByAppointment(
      String appointmentId) async {
    try {
      String url =
          "${prefs.getBool(isFamily) == true ? '/profile/caretaker/dependent/${patient.id}/appointments/$appointmentId/encounter?includePrescriptions=true&includeSoep=true' :
           '/profile/patient/appointments/$appointmentId/encounter?includePrescriptions=true&includeSoep=true'}";
      print("esta es $url");
      MedicalRecord medicalRecord;
      Response response = await dioHealthCore.get(url);
      if (response.statusCode == 200) {
        print(response.data);
        medicalRecord = MedicalRecord.fromJson(response.data);
        return medicalRecord;
      }
      throw Failure("Response status desconocido ${response.statusCode}");
    } catch (e) {
      print("ERROR $e");
      throw Failure(genericError);
    }
  }
}

Future<None> getMedicalRecords() async {
  //TODO: check this aproach
  final String url =
      "${prefs.getBool(isFamily) == true ? 'profile/takecare/dependent/${patient.id}/relatedEncounters?includePrescriptions=false&includeSoep=false&lastOnly=true' : '/profile/patient/relatedEncounters?includePrescriptions=false&includeSoep=false&lastOnly=true'}"
          .trim();
  print("esta es $url");
  Response response = await dioHealthCore.get(url);
  try {
    allMedicalData = List<MedicalRecord>.from(
        response.data.map((x) => MedicalRecord.fromJson(x[0])));
  } catch (e) {
    print("ERROR $e");
  }
  return const None();
}
