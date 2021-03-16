import 'package:boldo/network/connection_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/offline/offline_screen.dart';

var dio = Dio();
var dioKeyCloack = Dio();
void initDio({@required GlobalKey<NavigatorState> navKey}) {
  const storage = FlutterSecureStorage();
  String baseUrl = String.fromEnvironment('SERVER_ADDRESS',
      defaultValue: DotEnv().env['SERVER_ADDRESS']);

  dio.options.baseUrl = baseUrl;
  dio.options.headers['content-Type'] = 'application/json';
  dio.options.headers['accept'] = 'application/json';
  dio.options.connectTimeout = 5000; //5s
  dio.options.receiveTimeout = 3000;
  String accessToken;
  FlutterAppAuth appAuth = FlutterAppAuth();
  //setup interceptors
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options) async {
        accessToken = await storage.read(key: "access_token");
        options.headers["authorization"] = "bearer $accessToken";

        return options;
      },
      onError: (DioError error) async {
        if (error.response?.statusCode == 403) {
          try {
            await storage.deleteAll();
            accessToken = null;

            navKey.currentState.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(setLoggedOut: true),
              ),
              (route) => false,
            );
          } catch (e) {
            print(e);
          }
        } else if (error.response?.statusCode == 401) {
          if (accessToken == null) {
            await storage.deleteAll();

            return error;
          }
          RequestOptions options = error.response.request;
          if ("bearer $accessToken" != options.headers["authorization"]) {
            options.headers["authorization"] = "bearer $accessToken";
            return dio.request(options.path, options: options);
          }
          dio.lock();
          dio.interceptors.responseLock.lock();
          dio.interceptors.errorLock.lock();

          String keycloakRealmAddress = String.fromEnvironment(
              'KEYCLOAK_REALM_ADDRESS',
              defaultValue: DotEnv().env['KEYCLOAK_REALM_ADDRESS']);
          final String refreshToken = await storage.read(key: "refresh_token");

          try {
            final TokenResponse result = await appAuth.token(TokenRequest(
                'boldo-patient', 'com.penguin.boldo:/login',
                discoveryUrl:
                    '$keycloakRealmAddress/.well-known/openid-configuration',
                refreshToken: refreshToken,
                scopes: ['openid', 'offline_access']));
            await storage.write(key: "access_token", value: result.accessToken);
            await storage.write(
                key: "refresh_token", value: result.refreshToken);
            accessToken = result.accessToken;
            dio.unlock();
            dio.interceptors.responseLock.unlock();
            dio.interceptors.errorLock.unlock();
            //retry request
            return dio.request(options.path, options: options);
          } catch (e) {
            dio.unlock();
            dio.interceptors.responseLock.unlock();
            dio.interceptors.errorLock.unlock();
            await storage.deleteAll();
            accessToken = null;

            navKey.currentState.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(setLoggedOut: true),
              ),
              (route) => false,
            );
            return error;
          }
        }
        ConnectionStatusSingleton connectionStatus =
            ConnectionStatusSingleton.getInstance();
        bool hasInternet = await connectionStatus.checkConnection();
        if (!hasInternet) {
          navKey.currentState.push(
            MaterialPageRoute(
              builder: (context) => const OfflineScreen(),
            ),
          );
        }
        return error;
      },
    ),
  );
}

void initDioAccesKeycloack({@required GlobalKey<NavigatorState> navKey}) {
  const storage = FlutterSecureStorage();
  String baseUrl = String.fromEnvironment('KEYCLOAK_PTI_API',
      defaultValue: DotEnv().env['KEYCLOAK_PTI_API']);

  dioKeyCloack.options.baseUrl = baseUrl;
  dioKeyCloack.options.headers['content-Type'] = 'application/json';
  dioKeyCloack.options.headers['accept'] = 'application/json';
  dioKeyCloack.options.connectTimeout = 5000; //5s
  dioKeyCloack.options.receiveTimeout = 3000;
  String accessToken;
  FlutterAppAuth appAuth = FlutterAppAuth();
  //setup interceptors
  dioKeyCloack.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options) async {
        // accessToken = await storage.read(key: "access_token");
        // options.headers["authorization"] = "bearer $accessToken";

        // return options;
      },
      onError: (DioError error) async {
        if (error.response?.statusCode == 403) {
          try {
            await storage.deleteAll();
            accessToken = null;

            navKey.currentState.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(setLoggedOut: true),
              ),
              (route) => false,
            );
          } catch (e) {
            print(e);
          }
        } else if (error.response?.statusCode == 401) {
          if (accessToken == null) {
            await storage.deleteAll();

            return error;
          }
          RequestOptions options = error.response.request;
          if ("bearer $accessToken" != options.headers["authorization"]) {
            options.headers["authorization"] = "bearer $accessToken";
            return dioKeyCloack.request(options.path, options: options);
          }
          dioKeyCloack.lock();
          dioKeyCloack.interceptors.responseLock.lock();
          dioKeyCloack.interceptors.errorLock.lock();

          String keycloakRealmAddress = String.fromEnvironment(
              'KEYCLOAK_REALM_ADDRESS',
              defaultValue: DotEnv().env['KEYCLOAK_REALM_ADDRESS']);
          final String refreshToken = await storage.read(key: "refresh_token");

          try {
            final TokenResponse result = await appAuth.token(TokenRequest(
                'boldo-patient', 'com.penguin.boldo:/login',
                discoveryUrl:
                    '$keycloakRealmAddress/.well-known/openid-configuration',
                refreshToken: refreshToken,
                scopes: ['openid', 'offline_access']));
            await storage.write(key: "access_token", value: result.accessToken);
            await storage.write(
                key: "refresh_token", value: result.refreshToken);
            accessToken = result.accessToken;
            dioKeyCloack.unlock();
            dioKeyCloack.interceptors.responseLock.unlock();
            dioKeyCloack.interceptors.errorLock.unlock();
            //retry request
            return dioKeyCloack.request(options.path, options: options);
          } catch (e) {
            dioKeyCloack.unlock();
            dioKeyCloack.interceptors.responseLock.unlock();
            dioKeyCloack.interceptors.errorLock.unlock();
            await storage.deleteAll();
            accessToken = null;

            navKey.currentState.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(setLoggedOut: true),
              ),
              (route) => false,
            );
            return error;
          }
        } else {
          ConnectionStatusSingleton connectionStatus =
              ConnectionStatusSingleton.getInstance();
          bool hasInternet = await connectionStatus.checkConnection();
          if (!hasInternet) {
            navKey.currentState.push(
              MaterialPageRoute(
                builder: (context) => const OfflineScreen(),
              ),
            );
          }
          return error;
        }

        return error;
      },
    ),
  );
}
