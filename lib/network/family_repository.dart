import 'dart:convert';

import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/Relationship.dart';
import 'package:boldo/models/User.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:boldo/utils/translate_backend_message.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'http.dart';

class FamilyRepository {

  Future<None>? getDependents() async {
    try {
      Response response = await dio.get("/profile/caretaker/dependents");
      if (response.statusCode == 200) {
        families =
        List<Patient>.from(response.data.map((patient) =>
          Patient.fromJson(patient)
        ));
        return const None();
      } else if (response.statusCode == 204) {
        families = List<Patient>.from([]);
        return const None();
      }
      families = List<Patient>.from([]);
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener los familiares");
    } on Failure catch (exception, stacktrace){
      captureMessage(
        message: exception.message,
        stackTrace: stacktrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace) {
      families = List<Patient>.from([]);
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      families = List<Patient>.from([]);
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<List<Patient>>? getManagements() async {
    try {
      Response response = await dio.get("/profile/patient/caretakers");
      if (response.statusCode == 200) {
        return List<Patient>.from(
            response.data.map((patient) =>
                Patient.fromJson(patient)));
      } else if (response.statusCode == 204) {
        return List<Patient>.from([]);
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener los gestores");
    } on Failure catch (exception, stackTrace) {
      families = List<Patient>.from([]);
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch (exception, stackTrace) {
      families = List<Patient>.from([]);
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    } catch (exception, stackTrace) {
      families = List<Patient>.from([]);
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
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
      throw Failure("No se puede borrar el gestor");
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

  /// set [user] in the main the patient obtained with his [QrCode]
  Future<None>? getDependent(String qrCode) async {
    try {
      Response response =
      await dio.get(
        "/profile/caretaker/dependent/qrcode/decode",
        queryParameters: {
          'qr':qrCode,
        }
      );
      if (response.statusCode == 200) {
        // set the user obtained from the server
        user = User.fromJson(response.data);
        return const None();
      }
      // throw an error if isn't a know status code
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      try {
        // check if has message error
        if (exception.response?.data['messages'].isNotEmpty) {
          // get the first message error and search a coincidence into [errorInQrValidation]
          // that we know locally
          if (errorsTranslate.containsKey(
              exception.response?.data['messages'].first)) {
            // set the error
            throw Failure(
                errorsTranslate[exception.response?.data['messages']
                    .first] ?? genericError,
                response: exception.response
            );
          }else {
            // has a message unknown
            throw Failure(genericError, response: exception.response);
          }
        }else {
          // no has a message
          throw Failure(genericError, response: exception.response);
        }
      }on Failure catch(exception) {
        // the Failure was sent on captureError, in this case, isn't necessary emit
        // a message to sentry
        // throw a generic error if we not know the message error obtained from the server
        throw Failure(exception.message);
      }on Exception catch (exception, stackTrace) {
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
    } on Failure catch(exception, stacktrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stacktrace,
        response: exception.response,
      );
      throw Failure(exception.message);
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

  Future<None>? setDependent(bool isNew) async {
    try {
      var data = isNew ? user.toJsonNewPatient() : user.toJsonExistPatient();
      print(data);
      Response response =
      await dio.post("/profile/caretaker/dependent", data: data);
      if (response.statusCode == 200) {
        return const None();
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch (exception, stackTrace){
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
    } on Exception catch (exception, stackTrace){
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pudo añadir al dependiente. Por favor, reintente más tarde.");
    } on Failure catch (exception, stackTrace) {
      // send error to sentry
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

  Future<None>? unlinkDependent(String id) async {
    try {
      Response response =
      await dio.put("/profile/caretaker/inactivate/dependent/$id");
      if (response.statusCode == 200) {
        return const None();
      } else if (response.statusCode == 204) {
        throw Failure("El familiar ya fue borrado con anterioridad");
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pudo borrar al familiar");
    } on Failure catch (exception, stackTrace) {
      // send error to sentry
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
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  Future<None>? getRelationships() async {
    try {
      Response response = await dio.get("/profile/caretaker/relationships");
      if (response.statusCode == 200) {
        print(response.data);
        relationTypes = List<Relationship>.from(
            response.data.map((relationship) => Relationship.fromJson(relationship)));
        return const None();
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener las relaciones");
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

}