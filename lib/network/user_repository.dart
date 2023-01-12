import 'dart:convert';
import 'dart:io';

import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/models/QRCode.dart';
import 'package:boldo/models/Relationship.dart';
import 'package:boldo/models/User.dart';
import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../main.dart';
import '../models/Appointment.dart';
import '../models/Doctor.dart';
import '../provider/auth_provider.dart';
import '../provider/user_provider.dart';
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

  final Map<String,String> errorInQrValidation = {
    "The dependent and the caretaker are the same": "El Código pertenece al mismo paciente",
    "QR code does not exist":"El código QR no existe",
    "Invalid QR code":"El código QR no es válido",
    "Expired QR code":"El código QR ya expiró",
  };

  Future<None>? getPatient(String? id) async {
    try {
      Response response = id == null
          ? await dio.get("/profile/patient")
          : await dio.get("/profile/caretaker/dependent/$id");
      if (response.statusCode == 200) {
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
      throw Failure("No se puede obtener el usuario");
    } catch (e) {
      throw Failure("No se puede obtener el usuario");
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
      throw Failure("No se puede borrar el gestor");
    } catch (e) {
      throw Failure(genericError);
    }
  }

  /// set [user] in the main the patient obtained with his [QrCode]
  Future<None>? getDependent(String qrCode) async {
    try {
      Response response =
          await dio.get("/profile/caretaker/dependent/qrcode/decode?qr=$qrCode");
      if (response.statusCode == 200) {
        // set the user obtained from the server
        user = User.fromJson(response.data);
        return const None();
      }
      // throw an error if isn't a know status code
      throw Failure('Unknown StatusCode ${response.statusCode}');
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

      // check if has message error
      if(exception.response?.data['messages'].isNotEmpty)
        // get the first message error and search a coincidence into [errorInQrValidation]
        // that we know locally
        if( errorInQrValidation.containsKey(exception.response?.data['messages'].first))
          // set the error
          throw Failure(
            errorInQrValidation[exception.response?.data['messages'].first]?? genericError
          );

      // throw a generic error if we not know the message error obtained from the server
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
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
      if(patientAndDependentAreTheSameErrors.contains(exception.response?.data['messages'].join())){
        throw Failure("El familiar no puede ser el mismo que el principal");
      }else if(relationshipWithDependentAlreadyExistErrors.contains(exception.response?.data['messages'].join())){
        throw Failure("El familiar ya se encuentra asignado");
      }
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
      throw Failure("Error al asociar al familiar");
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
      throw Failure("No se puede donde subir la foto");
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
      if (errorInFrontSide.contains(exception.response?.data['messages'].join())) {
        photoStage = UrlUploadType.frontal;
        throw Failure("Error al validar la parte frontal");
      } else if (errorInBackSide
          .contains(exception.response?.data['messages'].join())) {
        photoStage = UrlUploadType.back;
        throw Failure("Error al validar la parte posterior");
      } else if (errorInSelfie.contains(exception.response?.data['messages'].join())) {
        photoStage = UrlUploadType.selfie;
        throw Failure("Error al validar la selfie");
      }
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      await Sentry.captureMessage(
          exception.toString(),
          params: [
            {
              'responseError': exception,
              'patient': prefs.getString("userId"),
              'access_token': await storage.read(key: 'access_token')
            },
            stackTrace
          ]
      );
      throw Failure('${exception.toString().length > 60 ? '$genericError' : exception}');
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

  Future<None>? logout(BuildContext context) async {
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
      throw Failure("No se pudo cerrar la sesion de forma adecuada");
    } catch (exception, stackTrace) {
      print(exception);
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
      throw Failure("Response status desconocido ${response.statusCode}");
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
      throw Failure("No se puede obtener el registro médico");
    } catch (e) {
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
      throw Failure("Response status desconocido ${response.statusCode}");
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
      throw Failure("No se puede obtener el registro médico");
    } catch (e) {
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
        throw Failure("Status ${responseAppointments.statusCode}");
      }
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
    } catch (e) {
      throw Failure("Error al obtener las citas");
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
        throw Failure("Status ${responseAppointments.statusCode}");
      }
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
      throw Failure("No se pudo obtener los estudios medicos");
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
      throw Failure("Error al obtener los estudios medicos");
    }
  }

  Future<List<Prescription>>? getPrescriptions() async {
    try{
      Response responsePrescriptions;
      if (!(prefs.getBool(isFamily)?? false))
        responsePrescriptions = await dio.get("/profile/patient/prescriptions");
      else
      responsePrescriptions = await dio
          .get("/profile/caretaker/dependent/${patient.id}/prescriptions");

      if(responsePrescriptions.statusCode == 200) {
        return List<Prescription>.from(
            responsePrescriptions.data["prescriptions"]
                .map((i) => Prescription.fromJson(i)));
      }else if(responsePrescriptions.statusCode == 204){
        return [];
      }
      throw Failure("Response code ${responsePrescriptions.statusCode}");
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
      throw Failure("No fue posible obtener las recetas");
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
      throw Failure("No fue posible obtener la receta");
    }catch (exception, stackTrace){
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
      throw Failure("No fue posible obtener la receta");
    }
  }

  Future<QRCode>? getQrCode() async {
    try {
      String url = '/profile/patient/qrcode/generate';
      QRCode qrCode;
      Response response = await dio.post(url);
      if (response.statusCode == 200) {
        qrCode = QRCode.fromJson(response.data);
        return qrCode;
      }
      throw Failure("Response status desconocido ${response.statusCode}");
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
      throw Failure("No se puede obtener el óodigo Qr");
    } catch (e) {
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
