import 'dart:convert';
import 'dart:io';

import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/environment.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/User.dart';
import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/translate_backend_message.dart';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../main.dart';
import '../models/Appointment.dart';
import 'http.dart';

class UserRepository {

  Future<None>? getPatient(String? id) async {
    try {
      Response response = id == null
          ? await dio.get("/profile/patient")
          : await dio.get("/profile/caretaker/dependent/$id");
      if (response.statusCode == 200) {

        // clear oldPatient data
        organizationsPostulated = [];
        patient = Patient.fromJson(response.data);
        // Update prefs in Principal Patient
        if(!(prefs.getBool(isFamily)?? false)) {
          prefs.setString("profile_url", patient.photoUrl ?? '');
          prefs.setString("userId", patient.id ?? '');
          await prefs.setString("name", response.data['givenName']!= null ? toLowerCase(response.data['givenName']!) : '');
          await prefs.setString("lastName", response.data['familyName']!= null ? toLowerCase(response.data['familyName']!) : '');
          await prefs.setString("identifier", response.data['identifier'] ?? '');
        }
        return const None();
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener el usuario");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      if(exception.response != null) {
        // if has a response the status is unknown
        throw Failure(genericError);
      }else {
        // if doesn't have response, is a unknown failure
        throw Failure(exception.message);
      }
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace){
      captureMessage(
        message: exception.toString(),
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<None>? editProfile(Patient patientData) async {
    try {

      //copy data to add international code
      patientData = Patient.fromJson(patientData.toJson());

      // add international py code
      patientData.phone = addInternationalPyNumber(patientData.phone);
      if(!(prefs.getBool(isFamily)?? false))
        await dio.post("/profile/patient", data: patientData.toJson());
      else
        await dio.put("/profile/caretaker/dependent/${patient.id}", data: patientData.toJson());

      // Set new profile info
      patient = Patient.fromJson(patientData.toJson());

      // Update prefs in Principal Patient
      if(!(prefs.getBool(isFamily)?? false))
        prefs.setString("profile_url", patient.photoUrl?? '');
      return const None();
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se puede actualizar los datos");
    } catch (e) {
      throw Failure("Ocurrio un error");
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
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se puede obtener los familiares");
    } catch (e) {
      families = List<Patient>.from([]);
      throw Failure(genericError);
    }
  }

  Future<List<Patient>>? getManagements() async {
    try {
      Response response = await dio.get("/profile/patient/caretakers");
      if (response.statusCode == 200) {
        return List<Patient>.from(
            response.data.map((i) => Patient.fromJson(i)));
      } else if (response.statusCode == 204) {
        return List<Patient>.from([]);
      }
      throw Failure(genericError);
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se puede obtener los gestores");
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? unlinkCaretaker(String id) async {
    try {
      Response response =
      await dio.put("/profile/patient/inactivate/caretaker/$id");
      if (response.statusCode == 200) {
        return const None();
      } else if (response.statusCode == 204) {
        throw Failure("El gestor ya fue borrado con anterioridad");
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede actualizar los datos");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      if(exception.response != null) {
        // if has a response the status is unknown
        throw Failure(genericError);
      }else {
        // if doesn't have response, is a unknown failure
        throw Failure(exception.message);
      }
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace){
      captureMessage(
        message: exception.toString(),
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<List<MedicalRecord>> getMedicalRecords() async {
    Response response = await dio.get(
        "/profile/patient/relatedEncounters?includePrescriptions=false&includeSoep=false&lastOnly=true");
    late List<MedicalRecord> list;
    try {
      list = List<MedicalRecord>.from(
          response.data.map((x) => MedicalRecord.fromJson(x[0])));
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se puede obtener los registros medicos");
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
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se puede obtener las relaciones");
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
    } on DioError catch (exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      try {
        if (patientAndDependentAreTheSameErrors.contains(
            exception.response?.data['messages'].join())) {
          throw Failure("El familiar no puede ser el mismo que el principal");
        } else if (relationshipWithDependentAlreadyExistErrors.contains(
            exception.response?.data['messages'].join())) {
          throw Failure("El familiar ya se encuentra asignado");
        }
        throw Failure(genericError);
      }catch (error){
        throw Failure("Error al asociar al familiar");
      }
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? linkWithoutCi(String givenName, String familyName,
      String birthday, String gender, String identifier, String relationShipCode) async {
    try {
      var data = {
        'givenName': givenName,
        'familyName': familyName,
        'birthDate': birthday,
        'gender': gender,
        'identifier': identifier,
        'relationshipCode': relationShipCode
      };
      Response response =
        await dio.post("/profile/caretaker/dependent", data: jsonEncode(data));
      if (response.statusCode == 200) {
        return const None();
      }
      // send unknown status code to sentry
      await Sentry.captureMessage(
        'Status code unknown',
        params: [
          {
            "path": response.realUri,
            "data": response.data,
            "patient": prefs.getString("userId"),
            "responseError": response.data,
            "status": response.statusCode,
            'access_token': await storage.read(key: 'access_token')
          }
        ],
      );
      throw Failure(genericError);
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se pudo añadir al dependiente. Por favor, reintente más tarde.");
    } catch (exception, stackTrace) {
      // send error to sentry
      await Sentry.captureMessage(
          exception.toString(),
          params: [
            {
              'patient': prefs.getString("userId"),
              'access_token': await storage.read(key: 'access_token')
            },
            stackTrace
          ]
      );
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
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se pudo borrar al familiar");
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<List<OrganizationWithAvailabilities>>? getAvailabilities({
    AppointmentType? appointmentType,
    required String id,
    required DateTime startDate,
    required DateTime endDate,
    required List<Organization?>? organizations}) async {

    String? _organizations = organizations?.map((e) => e?.id?? "").toList().join(",");
    try {


      String? appointmentTypeString = appointmentType == AppointmentType.InPerson
          ? "A": appointmentType == AppointmentType.Virtual ?"V": null;

      //subtract a second to get to 23:59:59 time until 00:00:00 next day
      endDate = endDate.subtract(const Duration(seconds: 1));

      dynamic queryParams = {
        'appointmentType': appointmentTypeString,
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
        'organizationIdList': _organizations,
      };

      // remove null values to solve null compare in server
      queryParams.removeWhere((key, value) => value == null);

      Response response;
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio.get('/profile/caretaker/dependent/${patient.id}/doctors/$id/availability',
            queryParameters: queryParams
        );
      } else {
        // the query is made
        response = await dio.get('/profile/patient/doctors/$id/availability',
            queryParameters: queryParams
        );
      }
      if (response.statusCode == 200) {
        List<OrganizationWithAvailabilities>? allAvailabilities = [];
        response.data.forEach((v) {
          allAvailabilities.add(OrganizationWithAvailabilities.fromJson(v));
        });
        // set nextAvailability to local time
        for ( OrganizationWithAvailabilities availability in allAvailabilities){
          availability.nextAvailability?.availability = DateTime.parse(
              availability.nextAvailability?.availability?? DateTime.now().toString()
          ).toLocal().toString();
          // set list of availabilities to local time
          for(NextAvailability? nextAvailability in availability.availabilities){
            nextAvailability?.availability = DateTime.parse(
                nextAvailability.availability?? DateTime.now().toString()
            ).toLocal().toString();
          }
        }
        return allAvailabilities;
      } else if (response.statusCode == 204) {
        throw Failure("No se encuentra disponible");
      }
      throw Failure(genericError);
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se pudo obtener la disponibilidad");
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se enviar el código");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      if(exception.response != null) {
        // if has a response the status is unknown
        throw Failure(genericError);
      }else {
        // if doesn't have response, is a unknown failure
        throw Failure(exception.message);
      }
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace){
      captureMessage(
        message: exception.toString(),
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<None>? getUrlFromServer(UrlUploadType urlUploadType) async {
    try {
      print('getUrlFromServer');
      String? isLogged = await storage.read(key: "access_token");
      final hash = await storage.read(key: "hash");
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
      if (response.statusCode == 200) {
        switch (urlUploadType) {
          case UrlUploadType.frontal:
            frontDniUrl = uploadUrlFromJson(response.data);
            await storage.write(key: "hash", value: frontDniUrl.hash);
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede subir los datos al servidor");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      if(exception.response != null) {
        // if has a response the status is unknown
        throw Failure(genericError);
      }else {
        // if doesn't have response, is a unknown failure
        throw Failure(exception.message);
      }
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace){
      captureMessage(
        message: exception.toString(),
        stackTrace: stackTrace,
      );
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No fue posible validar el número, intente nuevamente");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      if(exception.response != null) {
        // if has a response the status is unknown
        throw Failure(genericError);
      }else {
        // if doesn't have response, is a unknown failure
        throw Failure(exception.message);
      }
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace){
      captureMessage(
        message: exception.toString(),
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<None>? sendImagetoServer(
      UrlUploadType urlUploadType, XFile image) async {
    String url = "";
    try {
      print("send image to server");
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
            '${environment.SERVER_ADDRESS}$_url';
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
          throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
        }
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
      if(exception.response != null) {
        // if has a response the status is unknown
        throw Failure(genericError);
      }else {
        // if doesn't have response, is a unknown failure
        throw Failure(exception.message);
      }
    } on Exception catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } on Failure catch (exception, stackTrace){
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<None>? logout(BuildContext context) async {
    try {
      String baseUrlKeyCloack = environment.KEYCLOAK_REALM_ADDRESS;

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
      families = [];

      // this will be failed if the user change environment
      // the context was removed in the dio handle error
      try{
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding', (Route<dynamic> route) => false);
      }catch (e){
        // nothing to do
      }
      return const None();
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pudo cerrar la sesion de forma adecuada");
    } on Exception catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pudo cerrar la sesion de forma adecuada");
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
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se puede obtener la disponibilidad");
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
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se puede obtener el doctor");
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<List<Appointment>>? getPastAppointments(String date) async {
    Response responseAppointments;
    try {
      if (!(prefs.getBool(isFamily)?? false))
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
            .where((element) => ["closed", "locked","open"].contains(element.status))
            .toList();

        allAppointmets.sort((a, b) =>
            DateTime.parse(b.start!).compareTo(DateTime.parse(a.start!)));

        return allAppointmets;
      }

      throw Failure("Status deconocido ${responseAppointments.statusCode}");
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se puede obtener las citas");
    } catch (exception, stackTrace) {

      await Sentry.captureMessage(
          exception.toString(),
          params: [
            {
              'patient': prefs.getString("userId"),
              'access_token': await storage.read(key: 'access_token')
            },
            stackTrace
          ]
      );
      throw Failure(genericError);
    }
  }

  Future<List<Appointment>>? getPastAppointmentsBetweenDates(DateTime? date1, DateTime? date2) async {
    String firstDate = date1!= null? "?start=${DateTime(date1.year, date1.month, date1.day).toUtc().toIso8601String()}" : "?start=${DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String()}";
    String lastDate = date2!= null? "&end=${DateTime(date2.year, date2.month, date2.day).add(const Duration(days: 1)).toUtc().toIso8601String()}" : "";
    Response responseAppointments;
    try {
      if (!(prefs.getBool(isFamily)?? false))
        responseAppointments =
        await dio.get("/profile/patient/appointments$firstDate$lastDate");
      else
        responseAppointments = await dio.get(
            "/profile/caretaker/dependent/${patient.id}/appointments$firstDate$lastDate");

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

      throw Failure("Status deconocido ${responseAppointments.statusCode}");
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      throw Failure("No se puede obtener las citas");
    } catch (exception, stackTrace) {

      await Sentry.captureMessage(
          exception.toString(),
          params: [
            {
              'patient': prefs.getString("userId"),
              'access_token': await storage.read(key: 'access_token')
            },
            stackTrace
          ]
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
      MedicalRecord medicalRecord;
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        medicalRecord = MedicalRecord.fromJson(response.data['encounter']);
        return medicalRecord;
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener el registro médico");
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
    }
  }

  Future<MedicalRecord>? getMedicalRecordById(
      String id) async {
    try {
      String url =
          "${prefs.getBool(isFamily) == true ? '/profile/caretaker/dependent/${patient.id}/encounters/$id' :
      '/profile/patient/encounters/$id'}";
      MedicalRecord medicalRecord;
      Response response = await dio.get(url);
      if (response.statusCode == 200) {
        medicalRecord = MedicalRecord.fromJson(response.data['encounter']);
        return medicalRecord;
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener el registro médico");
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
    }
  }

  Future<List<Appointment>>? getAppointments() async {
    Response responseAppointments;
    try {
      if (!(prefs.getBool(isFamily)?? false))
        responseAppointments = await dio.get(
            "/profile/patient/appointments?start=${DateTime(DateTime
                .now()
                .year, DateTime
                .now()
                .month, DateTime
                .now()
                .day).toUtc().toIso8601String()}");
      else
        responseAppointments = await dio.get(
            "/profile/caretaker/dependent/${patient
                .id}/appointments?start=${DateTime(DateTime
                .now()
                .year, DateTime
                .now()
                .month, DateTime
                .now()
                .day).toUtc().toIso8601String()}");

      if (responseAppointments.statusCode == 200) {
        return List<Appointment>.from(
            responseAppointments.data["appointments"]
                .map((i) => Appointment.fromJson(i)));
      } else {
        throw Failure('Unknown StatusCode ${responseAppointments.statusCode}', response: responseAppointments);
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
    }
  }

  Future<List<DiagnosticReport>>? getDiagnosticRecords() async {
    Response responseAppointments;
    try {
      if (!(prefs.getBool(isFamily)?? false))
        responseAppointments = await dio.get(
            "/profile/patient/diagnosticReports");
      else
        responseAppointments = await dio.get(
            "/profile/caretaker/dependent/${patient.id}/diagnosticReports");

      if (responseAppointments.statusCode == 200) {
        return List<DiagnosticReport>.from(
            responseAppointments.data
                .map((i) => DiagnosticReport.fromJson(i)));
      } else if(responseAppointments.statusCode == 204) {
        return [];
      }else{
        throw Failure('Unknown StatusCode ${responseAppointments.statusCode}', response: responseAppointments);
      }
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pudo obtener los estudios medicos");
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
    }
  }

  Future<MedicalRecord>? getPrescription(String id) async {
    try{
      Response responsePrescriptions;
      if (!(prefs.getBool(isFamily)?? false))
        responsePrescriptions = await dio.get('/profile/patient/appointments/$id/encounter');
      else
        responsePrescriptions = await dio
            .get('/profile/caretaker/dependent/${patient.id}/appointments/$id/encounter');

      if(responsePrescriptions.statusCode == 200) {
        return MedicalRecord.fromJson(
            responsePrescriptions.data['encounter']);
      }
      throw Failure("Response code ${responsePrescriptions.statusCode}");
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No fue posible obtener la receta");
    }on Failure catch (exception, stackTrace) {
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
    }
  }

}

Future<None> getMedicalRecords() async {
  //TODO: check this aproach
  final String url =
      "${prefs.getBool(isFamily) == true ? 'profile/takecare/dependent/${patient.id}/relatedEncounters?includePrescriptions=false&includeSoep=false&lastOnly=true' : '/profile/patient/relatedEncounters?includePrescriptions=false&includeSoep=false&lastOnly=true'}"
          .trim();
  print("esta es $url");
  Response response = await dio.get(url);
  try {
    allMedicalData = List<MedicalRecord>.from(
        response.data.map((x) => MedicalRecord.fromJson(x[0])));
  } catch (e) {
    print("ERROR $e");
  }
  return const None();
}
