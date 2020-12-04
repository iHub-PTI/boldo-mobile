import 'package:boldo/network/connection_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/offline/offline_screen.dart';

var dio = Dio();

void initDio({@required GlobalKey<NavigatorState> navKey}) {
  const storage = FlutterSecureStorage();
  String baseUrl = String.fromEnvironment('SERVER_ADDRESS',
      defaultValue: DotEnv().env['SERVER_ADDRESS']);

  dio.options.baseUrl = baseUrl;
  dio.options.headers['content-Type'] = 'application/json';
  dio.options.headers['accept'] = 'application/json';

  String accessToken;
  FlutterAppAuth appAuth = FlutterAppAuth();
  //setup interceptors
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options) async {
        accessToken ??= await storage.read(key: "access_token");
        options.headers["authorization"] = "bearer $accessToken";

        return options;
      },
      onError: (DioError error) async {
        if (error.response?.statusCode == 403) {
          try {
            await storage.deleteAll();
            accessToken = null;
            navKey.currentState.pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(setLoggedOut: true),
              ),
            );
          } catch (e) {
            print(e);
          }
        } else if (error.response?.statusCode == 401) {
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
            navKey.currentState.pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(setLoggedOut: true),
              ),
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
