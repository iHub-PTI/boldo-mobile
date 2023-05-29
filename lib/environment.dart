import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Environment environment = Environment(
    envFile: ".env",
    envIceServerFile: ".env_ice_server_config",
);

class Environment {
  bool _isInitialized = false;
  final envFile;
  final envIceServerFile;

  Environment({required this.envFile, required this.envIceServerFile});

  /// Loads environment variables from the [envFile]
  Future<void> init() async {

    DotEnv env = DotEnv();

    DotEnv envIceServerConfig = DotEnv();

    await env.load(fileName: envFile);
    await envIceServerConfig.load(fileName: envIceServerFile);

    if(env.maybeGet("SERVER_ADDRESS") == null){
      throw Exception("SERVER_ADDRESS is not defined");
    }

    SERVER_ADDRESS = String.fromEnvironment(
        'SERVER_ADDRESS',
        defaultValue: env.env['SERVER_ADDRESS']!
    );

    if(env.maybeGet("SOCKETS_ADDRESS") == null){
      throw Exception("SOCKETS_ADDRESS is not defined");
    }

    SOCKETS_ADDRESS = String.fromEnvironment(
        'SOCKETS_ADDRESS',
        defaultValue: env.env['SOCKETS_ADDRESS']!
    );

    if(env.maybeGet("SERVER_ADDRESS_PASSPORT") == null){
      throw Exception("SERVER_ADDRESS_PASSPORT is not defined");
    }

    SERVER_ADDRESS_PASSPORT = String.fromEnvironment(
        'SERVER_ADDRESS_PASSPORT',
        defaultValue: env.env['SERVER_ADDRESS_PASSPORT']?? ""
    );

    if(env.maybeGet("KEYCLOAK_REALM_ADDRESS") == null){
      throw Exception("KEYCLOAK_REALM_ADDRESS is not defined");
    }

    KEYCLOAK_REALM_ADDRESS = String.fromEnvironment(
        'KEYCLOAK_REALM_ADDRESS',
        defaultValue: env.env['KEYCLOAK_REALM_ADDRESS']!
    );

    if(kReleaseMode) {
      if (env.maybeGet("SENTRY_DSN") == null) {
        throw Exception("SENTRY_DSN is not defined");
      }

      SENTRY_DSN = String.fromEnvironment(
          'SENTRY_DSN',
          defaultValue: env.env['SENTRY_DSN'] ?? ""
      );

      if (env.maybeGet("SENTRY_ENV") == null) {
        throw Exception("SENTRY_ENV is not defined");
      }

      SENTRY_ENV = String.fromEnvironment(
          'SENTRY_ENV',
          defaultValue: env.env['SENTRY_ENV'] ?? ""
      );
    }

    if(envIceServerConfig.maybeGet("ICE_SERVER_TURN_URL") == null){
      throw Exception("ICE_SERVER_TURN_URL is not defined");
    }

    if(envIceServerConfig.maybeGet("ICE_SERVER_TURN_USERNAME") == null){
      throw Exception("ICE_SERVER_TURN_USERNAME is not defined");
    }

    if(envIceServerConfig.maybeGet("ICE_SERVER_TURN_CREDENTIAL") == null){
      throw Exception("ICE_SERVER_TURN_CREDENTIAL is not defined");
    }

    ICE_SERVER_TURN_CONFIG = {
      'urls': String.fromEnvironment(
          'ICE_SERVER_TURN_URL',
          defaultValue: envIceServerConfig.env['ICE_SERVER_TURN_URL'] ?? ""
      ),
      'username': String.fromEnvironment(
          'ICE_SERVER_TURN_USERNAME',
          defaultValue: envIceServerConfig.env['ICE_SERVER_TURN_USERNAME'] ?? ""
      ),
      'credential': String.fromEnvironment(
          'ICE_SERVER_TURN_CREDENTIAL',
          defaultValue: envIceServerConfig.env['ICE_SERVER_TURN_CREDENTIAL'] ?? ""
      )
    };

    if(envIceServerConfig.maybeGet("ICE_SERVER_STUN_URL") == null){
      throw Exception("ICE_SERVER_STUN_URL is not defined");
    }

    if(envIceServerConfig.maybeGet("ICE_SERVER_STUN_USERNAME") == null){
      throw Exception("ICE_SERVER_STUN_USERNAME is not defined");
    }

    if(envIceServerConfig.maybeGet("ICE_SERVER_STUN_CREDENTIAL") == null){
      throw Exception("ICE_SERVER_STUN_CREDENTIAL is not defined");
    }

    ICE_SERVER_STUN_CONFIG = {
      'urls': String.fromEnvironment(
          'ICE_SERVER_STUN_URL',
          defaultValue: envIceServerConfig.env['ICE_SERVER_STUN_URL'] ?? ""
      ),
      'username': String.fromEnvironment(
          'ICE_SERVER_STUN_USERNAME',
          defaultValue: envIceServerConfig.env['ICE_SERVER_STUN_USERNAME'] ?? ""
      ),
      'credential': String.fromEnvironment(
          'ICE_SERVER_STUN_CREDENTIAL',
          defaultValue: envIceServerConfig.env['ICE_SERVER_STUN_CREDENTIAL'] ?? ""
      )
    };

    _isInitialized = true;
  }

  // stream controllers to update values
  StreamController<String> _serverAddressController = StreamController<String>.broadcast();
  StreamController<String> _socketAddressController = StreamController<String>.broadcast();
  StreamController<String> _serverPassportAddressController = StreamController<String>.broadcast();
  StreamController<String> _keycloakAddressController = StreamController<String>.broadcast();
  StreamController<String> _sentryDSNController = StreamController<String>.broadcast();
  StreamController<Map<String, dynamic>> _iceServerTurnConfig = StreamController<Map<String, dynamic>>.broadcast();
  StreamController<Map<String, dynamic>> _iceServerStunConfig = StreamController<Map<String, dynamic>>.broadcast();

  // streams to emit values to listeners
  Stream<String> get streamServerAddress => _serverAddressController.stream;
  Stream<String> get streamSocketAddress => _socketAddressController.stream;
  Stream<String> get streamPassportServerAddress => _serverPassportAddressController.stream;
  Stream<String> get streamKeycloakAddress => _keycloakAddressController.stream;
  Stream<String> get streamSentryDSNAddress => _sentryDSNController.stream;
  Stream<Map<String, dynamic>> get streamIceServerTurnConfig => _iceServerTurnConfig.stream;
  Stream<Map<String, dynamic>> get streamIceServerStunConfig => _iceServerStunConfig.stream;

  void updateServerValue(String value){
    SERVER_ADDRESS = value;
    _serverAddressController.sink.add(value);
  }

  void updateSocketValue(String value){
    SOCKETS_ADDRESS = value;
    _socketAddressController.sink.add(value);
  }

  void updatePassportServerValue(String value){
    SERVER_ADDRESS_PASSPORT = value;
    _serverPassportAddressController.sink.add(value);
  }

  void updateKeycloakServerValue(String value){
    KEYCLOAK_REALM_ADDRESS = value;
    _keycloakAddressController.sink.add(value);
  }

  void updateSentryDSNValue(String value){
    SENTRY_DSN = value;
    _sentryDSNController.sink.add(value);
  }

  void updateIceServerTurnConfigValue(Map<String, dynamic> value){
    ICE_SERVER_TURN_CONFIG = value;
    _iceServerTurnConfig.sink.add(value);
  }

  void updateIceServerStunConfig(Map<String, dynamic> value){
    ICE_SERVER_STUN_CONFIG = value;
    _iceServerStunConfig.sink.add(value);
  }

  /// This value can change remotely, you must be subscribe to [streamServerAddress]
  /// to listen changes dynamically
  late String SERVER_ADDRESS;

  /// This value can change remotely, you must be subscribe to [streamSocketAddress]
  /// to listen changes dynamically
  late String SOCKETS_ADDRESS;

  /// This value can change remotely, you must be subscribe to [streamPassportServerAddress]
  /// to listen changes dynamically
  late String SERVER_ADDRESS_PASSPORT;

  /// This value can change remotely, you must be subscribe to [streamKeycloakAddress]
  /// to listen changes dynamically
  late String KEYCLOAK_REALM_ADDRESS;

  /// This value can change remotely, you must be subscribe to [streamSentryDNSAddress]
  /// to listen changes dynamically
  String? SENTRY_DSN;

  /// This value can change remotely, you must be subscribe to [streamIceServerTurnConfig]
  /// to listen changes dynamically
  late Map<String, dynamic> ICE_SERVER_TURN_CONFIG;

  /// This value can change remotely, you must be subscribe to [streamIceServerStunConfig]
  /// to listen changes dynamically
  late Map<String, dynamic> ICE_SERVER_STUN_CONFIG;

  String? SENTRY_ENV;

}