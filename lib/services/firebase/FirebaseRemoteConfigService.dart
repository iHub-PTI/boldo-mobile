import 'dart:convert';

import 'package:boldo/app_config.dart';
import 'package:boldo/environment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FirebaseRemoteConfigService {

  FirebaseRemoteConfigService({
    required this.firebaseRemoteConfig,
  });

  final FirebaseRemoteConfig firebaseRemoteConfig;

  Future <void> init() async {
    try{
      await firebaseRemoteConfig.ensureInitialized();

      // set default values
      await firebaseRemoteConfig.setDefaults( {
        "SOCKETS_ADDRESS": environment.SERVER_ADDRESS,
        "SERVER_ADDRESS": environment.SERVER_ADDRESS,
        "SERVER_ADDRESS_PASSPORT": environment.SERVER_ADDRESS_PASSPORT,
        "KEYCLOAK_REALM_ADDRESS": environment.KEYCLOAK_REALM_ADDRESS,
        "SENTRY_DSN": environment.SENTRY_DSN?? '',
        "SENTRY_ENV": environment.SENTRY_ENV?? '',
        "ICE_SERVER_TURN": jsonEncode(environment.ICE_SERVER_TURN_CONFIG),
        "ICE_SERVER_STUN": jsonEncode(environment.ICE_SERVER_STUN_CONFIG.toString()),
        "APP_URL_DOWNLOAD": appConfig.APP_URL_DOWNLOAD,
        "DEFAULT_APP_URL_DOWNLOAD": appConfig.DEFAULT_APP_URL_DOWNLOAD,
        "LAST_AVAILABLE_VERSION": appConfig.LAST_AVAILABLE_VERSION,
        "LAST_STABLE_VERSION": appConfig.LAST_STABLE_VERSION,
        "TRACE_RATE_ERROR": appConfig.TRACE_RATE_ERROR?? 0.2,
        "ALL_DOCTORS_PAGE_COUNT": appConfig.ALL_DOCTORS_PAGE_COUNT,
        "ACCESS_ADD_DEPENDENT_CI": appConfig.ACCESS_ADD_DEPENDENT_CI,
        "ACCESS_ADD_DEPENDENT_QR": appConfig.ACCESS_ADD_DEPENDENT_QR,
        "ACCESS_ADD_DEPENDENT_WITHOUT_CI": appConfig.ACCESS_ADD_DEPENDENT_WITHOUT_CI,
      });

      // get values from server
      await firebaseRemoteConfig.fetchAndActivate();

      // set news values from server
      environment.updateServerValue(firebaseRemoteConfig.getString("SERVER_ADDRESS"));
      environment.updateSocketValue(firebaseRemoteConfig.getString("SOCKETS_ADDRESS"));
      environment.updatePassportServerValue(firebaseRemoteConfig.getString("SERVER_ADDRESS_PASSPORT"));
      environment.updateKeycloakServerValue(firebaseRemoteConfig.getString("KEYCLOAK_REALM_ADDRESS"));
      environment.updateSentryDSNValue(firebaseRemoteConfig.getString("SENTRY_DSN"));
      environment.updateIceServerTurnConfigValue(jsonDecode(firebaseRemoteConfig.getString("ICE_SERVER_TURN")));
      environment.updateIceServerStunConfig(jsonDecode(firebaseRemoteConfig.getString("ICE_SERVER_STUN")));
      appConfig.updateAppUrlDownloadValue(firebaseRemoteConfig.getString("APP_URL_DOWNLOAD"));
      appConfig.updateDefaultAppUrlDownloadValue(firebaseRemoteConfig.getString("DEFAULT_APP_URL_DOWNLOAD"));
      appConfig.updateLastAvailableVersionValue(firebaseRemoteConfig.getString("LAST_AVAILABLE_VERSION"));
      appConfig.updateLastStableVersionValue(firebaseRemoteConfig.getString("LAST_STABLE_VERSION"));
      appConfig.updateTraceRateErrorValue(firebaseRemoteConfig.getDouble("TRACE_RATE_ERROR"));
      appConfig.updateAllDoctorsPageCountValue(firebaseRemoteConfig.getInt("ALL_DOCTORS_PAGE_COUNT"));
      appConfig.updateAccessAddDependentCIValue(firebaseRemoteConfig.getBool("ACCESS_ADD_DEPENDENT_CI"));
      appConfig.updateAccessAddDependentQRValue(firebaseRemoteConfig.getBool("ACCESS_ADD_DEPENDENT_QR"));
      appConfig.updateAccessAddDependentWithoutCIValue(firebaseRemoteConfig.getBool("ACCESS_ADD_DEPENDENT_WITHOUT_CI"));

      // listen remote changes
      firebaseRemoteConfig.onConfigUpdated.listen((event) async {

        // get news values
        await firebaseRemoteConfig.fetchAndActivate();

        //update news values and notify listeners
        if(event.updatedKeys.contains("SERVER_ADDRESS")){
          // set new value
          environment.updateServerValue(firebaseRemoteConfig.getString("SERVER_ADDRESS"));
        }
        if(event.updatedKeys.contains("SOCKETS_ADDRESS")){
          // set new value
          environment.updateSocketValue(firebaseRemoteConfig.getString("SOCKETS_ADDRESS"));
        }
        if(event.updatedKeys.contains("SERVER_ADDRESS_PASSPORT")){
          // set new value
          environment.updatePassportServerValue(firebaseRemoteConfig.getString("SERVER_ADDRESS_PASSPORT"));
        }
        if(event.updatedKeys.contains("KEYCLOAK_REALM_ADDRESS")){
          // set new value
          environment.updateKeycloakServerValue(firebaseRemoteConfig.getString("KEYCLOAK_REALM_ADDRESS"));
        }
        if(event.updatedKeys.contains("SENTRY_DSN")){
          // set new value
          environment.updateSentryDSNValue(firebaseRemoteConfig.getString("SENTRY_DSN"));
        }
        if(event.updatedKeys.contains("ICE_SERVER_TURN")){
          // set new value
          var jsonString = firebaseRemoteConfig.getString("ICE_SERVER_TURN");
          var value = jsonDecode(jsonString);
          environment.updateIceServerTurnConfigValue(value);
        }
        if(event.updatedKeys.contains("ICE_SERVER_STUN")){
          // set new value
          var jsonString = firebaseRemoteConfig.getString("ICE_SERVER_STUN");
          var value = jsonDecode(jsonString);
          environment.updateIceServerStunConfig(value);
        }

        if(event.updatedKeys.contains("APP_URL_DOWNLOAD")){
          // set new value
          appConfig.updateAppUrlDownloadValue(firebaseRemoteConfig.getString("APP_URL_DOWNLOAD"));
        }
        if(event.updatedKeys.contains("DEFAULT_APP_URL_DOWNLOAD")){
          // set new value
          appConfig.updateDefaultAppUrlDownloadValue(firebaseRemoteConfig.getString("DEFAULT_APP_URL_DOWNLOAD"));
        }
        if(event.updatedKeys.contains("LAST_AVAILABLE_VERSION")){
          // set new value
          appConfig.updateLastAvailableVersionValue(firebaseRemoteConfig.getString("LAST_AVAILABLE_VERSION"));
        }
        if(event.updatedKeys.contains("LAST_STABLE_VERSION")){
          // set new value
          appConfig.updateLastStableVersionValue(firebaseRemoteConfig.getString("LAST_STABLE_VERSION"));
        }
        if(event.updatedKeys.contains("TRACE_RATE_ERROR")){
          // set new value
          appConfig.updateTraceRateErrorValue(firebaseRemoteConfig.getDouble("TRACE_RATE_ERROR"));
        }
        if(event.updatedKeys.contains("ALL_DOCTORS_PAGE_COUNT")){
          // set new value
          appConfig.updateAllDoctorsPageCountValue(firebaseRemoteConfig.getInt("ALL_DOCTORS_PAGE_COUNT"));
        }
        if(event.updatedKeys.contains("ACCESS_ADD_DEPENDENT_CI")){
          // set new value
          appConfig.updateAccessAddDependentCIValue(firebaseRemoteConfig.getBool("ACCESS_ADD_DEPENDENT_CI"));
        }
        if(event.updatedKeys.contains("ACCESS_ADD_DEPENDENT_QR")){
          // set new value
          appConfig.updateAccessAddDependentQRValue(firebaseRemoteConfig.getBool("ACCESS_ADD_DEPENDENT_QR"));
        }
        if(event.updatedKeys.contains("ACCESS_ADD_DEPENDENT_WITHOUT_CI")){
          // set new value
          appConfig.updateAccessAddDependentWithoutCIValue(firebaseRemoteConfig.getBool("ACCESS_ADD_DEPENDENT_WITHOUT_CI"));
        }
      });
    } on FirebaseException catch (exception, stackTrace){
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace){
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
  }

}
