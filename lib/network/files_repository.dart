import 'dart:io';
import 'dart:typed_data';

import 'package:boldo/app_config.dart';
import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'http.dart';

class FilesRepository {

  /// get a url to upload File on AzureBlob service, and the url to get the file
  /// uploaded, this will throw a Failure if the statusCode is unknown
  static Future<UploadUrl> getUploadURL() async {

    Response response;
    response = await dio.get('/presigned');

    if(response.statusCode == 200){
      UploadUrl uploadUrl = UploadUrl.fromJson(response.data);
      return uploadUrl;
    }
    throw Failure('Unknown StatusCode ${response.statusCode}', response: response);
  }

  /// On uploaded the file with http put method, this will return [None] type,
  /// if the file is too large, this will returned a [Failure]
  static Future<MapEntry<File, UploadUrl>> uploadFile({required File file, required UploadUrl url}) async {

    http.Response response;
    response = await http.put(
      Uri.parse(url), body: file.readAsBytesSync(),
    );

    if(response.statusCode == 201){
      return const None();
    }else if(response.statusCode == 413){
      throw Failure(
          'El archivo ${path.basename(file.path)} es demasiado grande',);
    }
    throw Failure('Unknown StatusCode ${response.statusCode}',);
  }

  /// If [localDio] isn't passed, by default it will download with http
  /// connection
  ///
  /// [queryParams] is used with [localDio]
  ///
  /// return the file as bytes
  static Future<Uint8List> getFile({
      Dio? localDio,
      Map<String, dynamic>? queryParams,
      final url,
  }) async {
    try {

      var data;

      if(localDio!= null){
        CancelToken _cancelToken = CancelToken();
        data = await localDio.get(url, queryParameters: queryParams, cancelToken: _cancelToken).
          timeout(Duration(milliseconds: appConfig.RECIVE_TIMEOUT_MILLISECONDS_DOWNLOAD_FILES.getValue), onTimeout: (){
            _cancelToken.cancel();
            throw DioError.receiveTimeout(
                timeout: Duration(milliseconds: appConfig.RECIVE_TIMEOUT_MILLISECONDS_DOWNLOAD_FILES.getValue), requestOptions: _cancelToken.requestOptions?? RequestOptions()
            );
        }
        );
      }else{
        data = await http.get(Uri.parse(url));
      }

      Uint8List bytes = data.data;
      return bytes;
    } on DioError catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
        data: {
          'url': url,
        },
      );
      if(exception.type == DioErrorType.receiveTimeout || exception.response?.statusCode == 502){
        throw Failure(appConfig.TIMEOUT_MESSAGE_DOWNLOAD_FILES.getValue);
      }
      throw Failure("Error al descargar el archivo");
    } catch (exception, stackTrace) {
      captureError(
        exception: exception,
        stackTrace: stackTrace,
        data: {
          'url': url,
        },
      );
      throw Failure("Error al descargar el archivo");
    }
  }

}