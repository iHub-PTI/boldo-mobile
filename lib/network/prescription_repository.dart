import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:dio/dio.dart';

import 'http.dart';

class PrescriptionRepository {

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

}