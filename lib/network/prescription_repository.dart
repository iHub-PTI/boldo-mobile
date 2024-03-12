import 'package:boldo/constants.dart';
import 'package:boldo/environment.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Encounter.dart';
import 'package:boldo/models/RemoteFile.dart';
import 'package:boldo/models/filters/PrescriptionFilter.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:dio/dio.dart';

import 'files_repository.dart';
import 'http.dart';

class PrescriptionRepository {

  static Future<List<Encounter>>? getPrescriptions({
    required PrescriptionFilter prescriptionFilter,
  }) async {

    Map<String, dynamic> _queryParameters = prescriptionFilter.toJson();

    try{
      Response responsePrescriptions;
      if (!(prefs.getBool(isFamily)?? false))
        responsePrescriptions = await dio.get(
          "/profile/patient/encounter/prescription",
          queryParameters: _queryParameters,
        );
      else
        responsePrescriptions = await dio
            .get(
          "/profile/caretaker/dependent/${patient.id}/encounter/prescription",
          queryParameters: _queryParameters,
        );

      if(responsePrescriptions.statusCode == 200) {
        return List<Encounter>.from(
            responsePrescriptions.data
                .map((i) => Encounter.fromJson(i)));
      }else if(responsePrescriptions.statusCode == 204){
        return [];
      }
      throw Failure('Unknown StatusCode ${responsePrescriptions.statusCode}', response: responsePrescriptions);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No fue posible obtener las recetas");
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
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

  static Future<RemoteFile> downloadPrescriptions ({
    required List<String?> prescriptionsId,
  }) async {
    try {

      String url;

      // remove null ids
      Map<String, dynamic> queryParams ={
        'encounter_ids': prescriptionsId.where((element) => element != null).toList(),
      };

      // declare a connection to download with access token and urlBase
      Dio _dioDownloader = Dio();
      initDio(navKey: navKey, dio: _dioDownloader, baseUrl: environment.SERVER_ADDRESS, responseType: ResponseType.bytes);

      // the query is made
      if(prefs.getBool(isFamily) ?? false) {
        url = '/profile/caretaker/dependent/${patient.id}/prescriptions/reports';
      }else{
        url = '/profile/patient/prescriptions/reports';
      }
      RemoteFile file = await FilesRepository.getFile(
        localDio: _dioDownloader,
        queryParams: queryParams,
        url: url,
      );
      return file;
    } on Failure catch (exception, stackTrace){
      throw exception;
    }catch (exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

}