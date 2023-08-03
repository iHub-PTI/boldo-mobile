import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:dio/dio.dart';

import 'http.dart';

class SpecializationRepository{

  Future<List<Specializations>>? getAllSpecializations() async {
    try {
      Response response = await dio.get('/specializations');
      if (response.statusCode == 200) {
        return List<Specializations>.from(
            response.data.map((i) => Specializations.fromJson(i)));
      }
      throw Failure('No fue posible obtener las especializaciones');
    } on DioError catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure('No fue posible obtener las especializaciones');
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }

}