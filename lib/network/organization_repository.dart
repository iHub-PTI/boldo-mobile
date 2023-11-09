import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class OrganizationRepository {

  final String errorRequestNotExist = "does not exists";

  final String errorRequestCannotDelete = "cannot be deleted";

  /// get organizations where the patient is subscribed
  Future<List<Organization>>? getOrganizations(Patient patientSelected) async {
    Response response;

    try {

      List<Organization> _organizationsSubscribed;

      if (patientSelected.id != prefs.getString('userId')) {
        response = await dio
            .get('/profile/caretaker/dependent/${patientSelected.id}/organizations');
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pueden obtener las Organizaciones");
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);

    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pueden obtener las Organizaciones");
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

  /// get all the unsubscribed organizations
  Future<List<Organization>>? getUnsubscribedOrganizations(Patient patientSelected) async {
    Response response;

    try {
      // the query is made
      if (patientSelected.id != prefs.getString('userId')) {
        response = await dio.get(
            '/profile/caretaker/dependent/${patientSelected.id}/organizations',
          queryParameters: {
            "subscribed": false,
          }
        );
      } else {
        response = await dio
            .get('/profile/patient/organizations',
            queryParameters: {
              "subscribed": false,
            }
        );
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
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);

    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pueden obtener las Organizaciones disponibles");
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

  /// get organizations where the patient is waiting for approving
  Future<List<OrganizationRequest>>? getPostulatedOrganizations(Patient patientSelected) async {
    Response response;

    try {
      if (patientSelected.id != prefs.getString('userId')) {
        response = await dio
            .get('/profile/caretaker/dependent/${patientSelected.id}/subscriptionRequests',
            queryParameters: {
              "status": "PD",
            }
        );
      } else {
        // the query is made
        response = await dio.get('/profile/patient/subscriptionRequests',
            queryParameters: {
              "status": "PD",
            }
        );
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
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pueden obtener las Organizaciones pendientes");
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

  Future<None>? subscribeToAnOrganization(String id, Patient patientSelected) async {
    try {
      Response response;
      if (patientSelected.id != prefs.getString('userId')) {
        response = await dio.post(
            '/profile/caretaker/dependent/${patientSelected.id}/subscribe/$id');
      } else {
        response = await dio.post('/profile/patient/subscribe/$id');
      }
      if(response.statusCode == 200)
        return None();

      // throw an error if isn't a know status code
      throw Failure('Unknown StatusCode ${response.statusCode}');
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure('No se pudo suscribir a la Organización');
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

  Future<None>? subscribeToManyOrganizations(List<Organization> organizations, Patient patientSelected) async {
    try {

      List<String> organizationsId = organizations.map((e) => e.id?? '').toList();

      dynamic data = {
        'organizationsId': organizationsId,
      };

      Response response;
      if (patientSelected.id != prefs.getString('userId')) {
        response = await dio.post(
            '/profile/caretaker/dependent/${patientSelected.id}/subscriptions',data: data);
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
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure('No se pudo suscribir a la Organización');
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

  Future<None>? unSubscribedOrganization(Organization organization, Patient patientSelected) async {
    Response response;

    try {

      // the query is made
      if (patientSelected.id != prefs.getString('userId')) {
        response = await dio
            .delete('/profile/caretaker/dependent/${patientSelected.id}/organization/${organization.id}');
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
      captureError(
        exception: exception,
        stackTrace: stackTrace,
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

  Future<None>? unSubscribedPostulation(OrganizationRequest organizationRequest, Patient patientSelected) async {
    Response response;

    try {

      // the query is made
      if (patientSelected.id != prefs.getString('userId')) {
        response = await dio
            .delete('/profile/caretaker/dependent/${patientSelected.id}/subscriptionRequest/${organizationRequest.id}');
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
      captureError(
        exception: exception,
        stackTrace: stackTrace,
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

  Future<None>? reorderByPriority(List<Organization> organizations, Patient patientSelected) async {

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
      if (patientSelected.id != prefs.getString('userId')) {
        response = await dio
            .put('/profile/caretaker/dependent/${patientSelected.id}/organizations/priorities', data: data);
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
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede establecer la prioridad");
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

  /// get all organizations by type
  Future<PagList<Organization>>? getOrganizationsByType({
    required OrganizationType organizationType,
    String? name
  }) async {
    Response response;

    try {

      Map<String, dynamic> queryParameters = {
        "active": true,
        "name": name,
      };

      // remove null values
      queryParameters.removeWhere((key, value) => value==null);


      // the query is made

      response = await dioBCM.get(
        '/profile/patient/organization/type/${organizationType.codeType}',
        queryParameters: queryParameters,
      );
      // there are organizations
      if (response.statusCode == 200) {
        PagList<Organization> result = PagList.fromJson(
            response.data,
            List<Organization>.from(
                response.data['items'].map((i) => Organization.fromJson(i))
            )
        );
        return result;
      } // doesn't have any organization
      else if (response.statusCode == 204) {
        // return empty list
        return PagList<Organization>(total: 0, items: []);
      }
      throw Failure('Unknown StatusCode ${response.statusCode}', response: response);

    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se pueden obtener las Organizaciones disponibles");
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
