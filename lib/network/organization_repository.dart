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

  final String errorRequestNotExist = "does not exists";

  final String errorRequestCannotDelete = "cannot be deleted";

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
      throw Failure("No se pueden obtener las Organizaciones disponibles");
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
  Future<List<OrganizationRequest>>? getPostulatedOrganizations() async {
    Response response;

    try {
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio
            .get('/profile/caretaker/dependent/${patient.id}/subscriptionRequests?status=PD');
      } else {
        // the query is made
        response = await dio.get('/profile/patient/subscriptionRequests?status=PD');
      }
      // there are organizations
      if (response.statusCode == 200) {
        return List<OrganizationRequest>.from(
            response.data.map((i) => OrganizationRequest.fromJson(i)));
      } // doesn't have any organization
      else if (response.statusCode == 204) {
        // return empty list
        return List<OrganizationRequest>.from([]);
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
      throw Failure("No se pueden obtener las Organizaciones pendientes");
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

  Future<None>? unSubscribedOrganization(Organization organization) async {
    Response response;

    try {

      // the query is made
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio
            .delete('/profile/caretaker/dependent/${patient.id}/organization/${organization.id}');
      } else {
        response = await dio.delete('/profile/patient/organization/${organization.id}');
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
    //   o	Si la organización no es de tipo BMO para el id indicado: "Organization {idOrganization}  is not BoldoMultiOrganization type"
    // o	Si se intenta eliminar una organización en la cual el paciente no tiene suscripción: "The patient {idPatient} is not part of the organization {idOrganization}"
    // o	Si el paciente no tiene ninguna organización asignada: "The patient {idPatient} is not part of any organization"
      try{
        if(exception.response?.data['message'].contains(errorRequestNotExist )){
          throw Failure("La solicitud a ${organization.name} no fue encontrada");
        }else if(exception.response?.data['message'].contains(errorRequestCannotDelete )){
          throw Failure("La solicitud a ${organization.name} ya no está entre los pendientes");
        }else{
          throw Failure("No se puede eliminar la suscripción");
        }
      }catch(e){
        throw Failure(genericError);
      }
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

  Future<None>? unSubscribedPostulation(OrganizationRequest organizationRequest) async {
    Response response;

    try {

      // the query is made
      if (prefs.getBool('isFamily') ?? false) {
        response = await dio
            .delete('/profile/caretaker/dependent/${patient.id}/subscriptionRequest/${organizationRequest.id}');
      } else {
        response = await dio.delete('/profile/patient/subscriptionRequest/${organizationRequest.id}');
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
      try {
        if (exception.response?.data['message']?.contains(
            errorRequestNotExist)) {
          throw Failure("La solicitud a ${organizationRequest
              .organizationName} no fue encontrada");
        } else if (exception.response?.data['message']?.contains(
            errorRequestCannotDelete)) {
          throw Failure("La solicitud a ${organizationRequest
              .organizationName} ya no está entre los pendientes");
        } else {
          throw Failure("No se puede eliminar la suscripción");
        }
      }catch(e){
        throw Failure(genericError);
      }
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
      throw Failure("No se puede establecer la prioridad");
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
