import 'dart:io';

import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<bool> validateAppVersion() async {
  try {
    String? backendVersion;
    // get app version from server
    if(Platform.isAndroid){
      // Get version from server for Android
      backendVersion = '1.2.7';
    }else if(Platform.isIOS){
      // Get version from server for IOS
      backendVersion = '1.1.8';
    }else{
      throw Failure("Unkown SO ${Platform.operatingSystem}");
    }


    // get package info
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    //validate locale version with server version
    // negative if the version from server is bigger than device version
    int validation = packageInfo.version.compareTo(backendVersion);

    return validation < 0;
  } on Failure catch (exception, stackTrace) {
    await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            'responseError': exception,
            'patient': prefs.getString("userId"),
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ]
    );
    throw Failure(genericError);
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
    throw Failure(genericError);
  } catch (exception, stackTrace) {
    await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            'responseError': exception,
            'patient': prefs.getString("userId"),
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ]
    );
    throw Failure(genericError);
  }
}