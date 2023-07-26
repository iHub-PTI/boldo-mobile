import 'dart:convert';

import 'package:boldo/services/sentry/send_error.dart';
import 'package:boldo/services/sentry/send_message.dart';
import 'package:dio/dio.dart';

Future <void> captureError({
  required Exception exception,
  StackTrace? stackTrace,
  dynamic ? data,
}) async{

  Map<String, String> tags = {};
  if(data.runtimeType == Map<String, String>)
    data?.forEach((key, value) => tags[key] = jsonEncode(value));

  if(exception is DioError){
    tags['data'] = jsonEncode(exception.response?.requestOptions.data);
  }

  if(exception is DioError){
    tags['params'] = jsonEncode(exception.response?.requestOptions.queryParameters);
  }

  if(exception is DioError){
    tags['responseData'] = jsonEncode(exception.response?.data);
  }

  await sendSentryError(
    exception: exception,
    stackTrace: stackTrace,
    tags: tags,
  );
}

Future <void> captureMessage({
  required String message,
  StackTrace? stackTrace,
  Map<String, dynamic>? data,
  Response? response,
}) async{

  Map<String, String> tags = {};
  if(data.runtimeType == Map<String, String>)
    data?.forEach((key, value) => tags[key] = jsonEncode(value));

  if(response != null){
    tags['data'] = jsonEncode(response.requestOptions.data);
    tags['params'] = jsonEncode(response.requestOptions.queryParameters);
  }

  await sendSentryMessage(
    message: message,
    stackTrace: stackTrace,
    tags: tags,
    params: data
  );
}

