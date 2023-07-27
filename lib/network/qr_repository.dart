import 'package:boldo/constants.dart';
import 'package:boldo/models/QRCode.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:dio/dio.dart';

import 'http.dart';

class QRRepository{

  /// Return a [QRCode] of the principal patient to use to add this patient in
  /// another family, this [QRCode] has a time duration defined by Backend service.
  Future<QRCode>? getQrCode() async {
    try {
      String url = '/profile/patient/qrcode/generate';
      QRCode qrCode;
      Response response = await dio.post(url);
      if (response.statusCode == 200) {
        qrCode = QRCode.fromJson(response.data);
        return qrCode;
      }
      throw Failure("Response status desconocido ${response.statusCode}", response: response);
    } on DioError catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure("No se puede obtener el óodigo Qr");
    } on Failure catch (exception, stackTrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stackTrace,
        response: exception.response,
      );
      throw Failure(genericError);
    } on Exception catch(exception, stackTrace){
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      throw Failure(genericError);
    }
  }
}