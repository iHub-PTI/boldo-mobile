import 'dart:convert';
import 'dart:io';

import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/User.dart';
import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../constants.dart';
import '../main.dart';
import 'http.dart';

class UserRepository {

  Future<Patient>? getPatient(String? id) async {
    try {
      Response response = id == null
          ? await dio.get("/profile/patient")
          : await dio.get("/profile/caretaker/dependent/$id");
      if(response.statusCode == 200){
        return Patient.fromJson(response.data);
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? getDependents() async {
    try {
      Response response = await dio.get("/profile/caretaker/dependent");
      print(response.data);
      print(response.statusCode);
      if(response.statusCode == 200){
        print(response.data.map((i) => Patient.fromJson(i)));
        families =  List<Patient>.from(
            response.data.map((i) => Patient.fromJson(i)));
        return None();
      }else if(response.statusCode == 204){
        families = List<Patient>.from([]);
        return None();
      }
      throw Failure(genericError);
    } catch (e) {
      print(e);
      throw Failure(genericError);
    }
  }

  Future<List<Patient>>? getManagements() async {
    try {
      Response response = await dio.get("/profile/patient/caretaker");
      if(response.statusCode == 200){
        return List<Patient>.from(
            response.data.map((i) => Patient.fromJson(i)));
      }else if(response.statusCode == 204){
        return List<Patient>.from([]);
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<User>? getDependent(String id) async {
    print("ID $id");
    try {
      Response response = await dio.get("/profile/caretaker/dependent/$id");
      if(response.statusCode == 200){
        print(response.data);
        return User.fromJson(response.data);
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
    }catch (e){
      print("ERROR $e");
    }
    print("GETTED");
    return list;
  }

  Future<List<String>>? getRelationships() async {
    try {
      Response response = await dio.get("/profile/caretaker/relationship");
      if(response.statusCode == 200){
        return List<String>.from(
            response.data.map((i) => i[0]));
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? setDependent(bool isNew) async {
    try {
      var data = isNew? user.toJsonNewPatient() :
      user.toJsonExistPatient();
      print(data);
      Response response = await dio.post("/profile/caretaker/dependent", data: data);
      if(response.statusCode == 200){
        return None();
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? sendUserPreliminaryProfile(BuildContext context) async {
    try {
      final String cellPhone = user.phone!;
      Response response = await dio.post("/preRegister/sedCode?cellphone=%2B$cellPhone");
      if(response.statusCode == 201){
        return None();
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
          url = isLogged == null ?
          "preRegister/s3/validateDocument/idCardParaguay/side1/uploadPresigned?hash=$hash" :
              "profile/caretaker/dependent/s3/validateDocument/idCardParaguay/side1/uploadPresigned" ;
          break;
        case UrlUploadType.back:
          url = isLogged == null ?
          "preRegister/s3/validateDocument/idCardParaguay/side2/uploadPresigned?hash=$hash" :
          "profile/caretaker/dependent/s3/validateDocument/idCardParaguay/side2/uploadPresigned?hash=$hash";
          break;
        case UrlUploadType.selfie:
          url = isLogged == null ?
          "preRegister/s4/validateSelfie/uploadPresigned?hash=$hash" :
          "profile/caretaker/dependent/s4/validateSelfie/uploadPresigned?hash=$hash";
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
            break;
          case UrlUploadType.back:
            backDniUrl = uploadUrlFromJson(response.data);
            break;
          case UrlUploadType.selfie:
            userSelfieUrl = uploadUrlFromJson(response.data);
            break;
          default:
        }

        return None();
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  Future<None>? validateUserPhone(String hash, BuildContext context) async {
    try{
      final String phone = user.phone!;
      final String password = user.password!;
      Response response = await dio.post("preRegister/validateCode?hash=$hash&phone=$phone");
      if(response.statusCode == 200){
        return None();
      }
      throw Failure('No fue posible validad el número, intente nuevamente');
    } catch (e) {
      throw Failure('No fue posible validad el número, intente nuevamente');
    }
  }

  Future<None>? sendImagetoServer(UrlUploadType urlUploadType, XFile image) async {
    try {
      print("send image to server");
      String url = "";
      String? isLogged = await storage.read(key: "access_token");
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
            _url = isLogged == null ?
            "preRegister/s3/validateDocument/idCardParaguay/side1/validate?hash=$hash" :
            "profile/caretaker/dependent/s3/validateDocument/idCardParaguay/side1/validate?hash=$hash";
            break;
          case UrlUploadType.back:
            _url = isLogged == null ?
            "preRegister/s3/validateDocument/idCardParaguay/side2/validate?hash=$hash" :
            "profile/caretaker/dependent/s3/validateDocument/idCardParaguay/side2/validate?hash=$hash";
            break;
          case UrlUploadType.selfie:
            _url = isLogged == null ?
            "preRegister/s4/validateSelfie/validate?hash=$hash" :
            "profile/caretaker/dependent/s4/validateSelfie/validate?hash=$hash";
            break;
          default:
        }
        final _finalUrl = Uri.parse(
            '${String.fromEnvironment('SERVER_ADDRESS', defaultValue: dotenv.env['SERVER_ADDRESS']!)}$_url');
        var response = await http.post(_finalUrl);
        if (response.statusCode == 200) {
          if(urlUploadType == UrlUploadType.selfie && isLogged != null){
            user = User.fromJson(jsonDecode(response.body));
          }
          return None();
        } else {
          return throw Failure(response.body);
        }
      }
      throw Failure(genericError);
    } catch (e) {
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
        return None();
      }
      throw Failure(genericError);
    } catch (e) {
      throw Failure(genericError);
    }
  }

  void logout(BuildContext context) async {
    try {
      String baseUrlKeyCloack = String.fromEnvironment(
          'KEYCLOAK_REALM_ADDRESS',
          defaultValue: dotenv.env['KEYCLOAK_REALM_ADDRESS']!);

      String? refreshToken =
      await storage.read(key: "refresh_token");
      Map<String, dynamic> body = {
        "refresh_token": refreshToken??'',
        "client_id": "boldo-patient"
      };
      var url = Uri.parse(
          "$baseUrlKeyCloack/protocol/openid-connect/logout");
      await http.post(url,
          body: body,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded"
          },
          encoding: Encoding.getByName("utf-8"));
      await prefs.setBool("onboardingCompleted", false);
      await storage.deleteAll();
      await prefs.clear();

      Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (Route<dynamic> route) => false);
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

}

Future<None> getMedicalRecords() async {
  Response response = await dioHealthCore.get(
      "/profile/patient/relatedEncounters?includePrescriptions=false&includeSoep=false&lastOnly=true");
  try {
    allMedicalData = List<MedicalRecord>.from(
        response.data.map((x) => MedicalRecord.fromJson(x[0])));
  }catch (e){
    print("ERROR $e");
  }
  return None();
}