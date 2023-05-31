import 'dart:convert';

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
