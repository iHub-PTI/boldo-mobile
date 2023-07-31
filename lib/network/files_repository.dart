import 'dart:io';

import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'http.dart';

class FilesRepository {

  /// get a url to upload File on AzureBlob service, and the url to get the file
  /// uploaded, this will throw a Failure if the statusCode is unknown
  Future<UploadUrl> getUploadURL() async {

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
  Future<None> uploadFile({required File file, required String url}) async {

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
}