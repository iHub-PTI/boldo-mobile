import 'dart:io';

import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class OrganizationRepository {

  /// get organizations where the patient is subscribed
  Future<List<Organization>>? getOrganizations() async {
    Response response;

    try {

      List<Organization> _organizationsSubscribed;

      if (prefs.getBool('isFamily') ?? false) {
        response = await dio
            .get('/profile/caretaker/dependent/${patient.id}/organizations');
      } else {
        // the query is made
        response = await dio.get('/profile/patient/organizations');
      }
      // there are organizations
      if (response.statusCode == 200) {
        _organizationsSubscribed = List<Organization>.from(
            response.data.map((i) => Organization.fromJson(i))
        );
        return _organizationsSubscribed;
      } // doesn't have any organization
      else if (response.statusCode == 204) {
        // return empty list
        return List<Organization>.from([]);
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
      throw Failure("No se pueden obtener las Organizaciones");
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

  /// get all the organizations
  Future<List<Organization>>? getAllOrganizations() async {
    Response response;

    try {
      // the query is made
      response = await dio.get('/organizations');
      // there are organizations
      if (response.statusCode == 200) {
        return List<Organization>.from(
            response.data.map((i) => Organization.fromJson(i)));
      } // doesn't have any organization
      else if (response.statusCode == 204) {
        // return empty list
        return List<Organization>.from([]);
      }

      // throw an error if isn't a know status code
      await Sentry.captureMessage(
        "unknownError ${response.statusCode}",
        params: [
          {
            "path": response.requestOptions.path,
            "data": response.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            'access_token': await storage.read(key: 'access_token')
          }
        ],
      );
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
      throw Failure("No se pueden obtener las Organizaciones");
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

  /// get all the unsubscribed organizations
  Future<List<Organization>>? getUnsubscribedOrganizations() async {
    Response response;

    try {
      // the query is made
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio.get(
            '/profile/caretaker/dependent/${patient.id}/organizations?subscribed=false');
      } else {
        response = await dio
            .get('/profile/patient/organizations?subscribed=false');
      }
      // there are organizations
      if (response.statusCode == 200) {
        return List<Organization>.from(
            response.data.map((i) => Organization.fromJson(i)));
      } // doesn't have any organization
      else if (response.statusCode == 204) {
        // return empty list
        return List<Organization>.from([]);
      }

      // throw an error if isn't a know status code
      await Sentry.captureMessage(
        "unknownError ${response.statusCode}",
        params: [
          {
            "path": response.requestOptions.path,
            "data": response.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            'access_token': await storage.read(key: 'access_token')
          }
        ],
      );
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
      throw Failure("No se pueden obtener las Organizaciones");
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

  /// get organizations where the patient is waiting for approving
  Future<List<Organization>>? getPostulatedOrganizations() async {
    Response response;

    try {
      /*if (prefs.getBool('isFamily') ?? false) {
        response = await dio
            .get('/profile/caretaker/dependent/${patient.id}/organizations');
      } else {
        // the query is made
        response = await dio.get('/profile/patient/organizations');
      }
      // there are organizations
      if (response.statusCode == 200) {
        return List<Organization>.from(
            response.data.map((i) => Organization.fromJson(i)));
      } // doesn't have any organization
      else if (response.statusCode == 204) {
        // return empty list
        return List<Organization>.from([]);
      }

       */
      return List<Organization>.from(organizationsPostulated);
      // throw an error if isn't a know status code
      //throw Failure('Unknown StatusCode ${response.statusCode}');
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
      throw Failure("No se pueden obtener las Organizaciones");
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

  Future<Organization>? getOrganizationId(String id) async {
    Response response;

    try {
      // the query is made
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio.get(
            '/profile/caretaker/dependent/${patient.id}/encounter/${id}/serviceRequests');
      } else {
        response = await dio
            .get('/profile/patient/encounter/${id}/serviceRequests');
      }
      // there are an organization
      if (response.statusCode == 200) {
        return Organization.fromJson(response.data);
      } // no organization
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
      throw Failure("No se puede obtener la oganizacion");
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

  Future<None>? subscribeToAnOrganization(String id) async {
    try {
      Response response;
      if (prefs.getBool(isFamily) ?? false) {
        response = await dio.post(
            '/profile/caretaker/dependent/${patient.id}/subscribe/$id');
      } else {
        response = await dio.post('/profile/patient/subscribe/$id');
      }
      if(response.statusCode == 200)
        return None();

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
      throw Failure('No se pudo suscribir a la Organización');
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

  Future<None>? subscribeToManyOrganizations(List<Organization> organizations) async {
    try {

      List<String> organizationsId = organizations.map((e) => e.id?? '').toList();

      dynamic data = {
        'organizationsId': organizationsId,
      };

      Response response;
      if (prefs.getBool(isFamily) ?? false) {
        response = await dio.post(
            '/profile/caretaker/dependent/${patient.id}/subscriptions',data: data);
      } else {
        response = await dio.post('/profile/patient/subscriptions', data: data);
      }
      if(response.statusCode == 200) {
        //TODO: persist locally where list of organizations pending accepted isn't developed
        organizationsPostulated.addAll(organizations);
        return None();
      }
      // throw an error if isn't a know status code
      throw Failure('Unknown StatusCode ${response.statusCode}');

    } on DioError catch (exception, stackTrace) {
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
      throw Failure('No se pudo suscribir a la Organización');
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

  Future<None>? unSubscribed(String id) async {
    Response response;

    try {

      // the query is made
      /*if (prefs.getBool('isFamily') ?? false) {
        response = await dio
            .post('/profile/caretaker/dependent/${patient.id}/organizations/unsubscribed/$id');
      } else {
        response = await dio.get('/profile/patient/organizations/unsubscribed/$id');
      }
      // there are organizations
      if (response.statusCode == 200) {
        return None();
      }

       */
      organizationsSubscribed.removeWhere((element) => element.id == id);
      return None();
      // throw an error if isn't a know status code
      //throw Failure('Unknown StatusCode ${response.statusCode}');
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
      throw Failure("No se puede eliminar la suscripción");
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

  Future<None>? unSubscribedPostulation(String id) async {
    Response response;

    try {

      // the query is made
      /*if (prefs.getBool('isFamily') ?? false) {
        response = await dio
            .post('/profile/caretaker/dependent/${patient.id}/organizations/unsubscribedPostulation/$id');
      } else {
        response = await dio.get('/profile/patient/organizations/unsubscribedPostulation/$id');
      }
      // there are organizations
      if (response.statusCode == 200) {
        return None();
      }

       */
      organizationsPostulated.removeWhere((element) => element.id == id);
      return None();
      // throw an error if isn't a know status code
      //throw Failure('Unknown StatusCode ${response.statusCode}');
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
      throw Failure("No se puede eliminar la suscripción");
    } on Failure catch (exception, stackTrace) {
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
      throw Failure(exception.message);
    }catch (exception, stackTrace) {
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

  Future<None>? reorderByPriority(List<Organization> organizations) async {

    try {
      Response response;

      List<dynamic> data = organizations.asMap().entries.map((e) =>
      {
        'patientId': patient.id,
        'organizationId': e.value.id,
        'priority': e.key+1, // 0->1, 1->2, ...
      }
      ).toList();

      // the query is made
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio
            .put('/profile/caretaker/dependent/${patient.id}/organizations/priorities', data: data);
      } else {
        response = await dio.put('profile/patient/organizations/priorities', data: data);
      }
      // there are organizations
      if (response.statusCode == 200) {
        return None();
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
      throw Failure("No se puede eliminar la suscripción");
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

}
