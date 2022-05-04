import 'package:boldo/network/connection_status.dart';
import 'package:boldo/screens/hero/hero_screen_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../main.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/offline/offline_screen.dart';

var dio = Dio();
var dioHealthCore = Dio();
void initDio({required GlobalKey<NavigatorState> navKey}) {
  String baseUrl = String.fromEnvironment('SERVER_ADDRESS',
      defaultValue: dotenv.env['SERVER_ADDRESS']!);

  dio.options.baseUrl = baseUrl;
  dio.options.headers['content-Type'] = 'application/json';
  dio.options.headers['accept'] = 'application/json';

  String? accessToken;
  FlutterAppAuth appAuth = FlutterAppAuth();
  //setup interceptors
  dio.interceptors.add(QueuedInterceptorsWrapper(
    onRequest: (options, handler) async {
      accessToken = (await storage.read(key: "access_token")??'');
      options.headers["authorization"] = "bearer $accessToken";

      return handler.next(options);
    },
    onError: (DioError error, handle) async {
      if (error.response?.statusCode == 403) {
        try {
          await storage.deleteAll();
          // ignore: null_check_always_fails
          accessToken = null;

          navKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(setLoggedOut: true),
            ),
            (route) => false,
          );
        } catch (e) {
          print(e);
        }
      } else if (error.response?.statusCode == 401) {
        print("401 DIO");
        if (accessToken == null) {
          await storage.deleteAll();

          return handle.next(error);
        }

        RequestOptions options = error.response!.requestOptions;
        Options optionsDio = Options(
            contentType: options.contentType,
            followRedirects: options.followRedirects,
            extra: options.extra,
            headers: options.headers,
            listFormat: options.listFormat,
            maxRedirects: options.maxRedirects,
            method: options.method,
            receiveDataWhenStatusError: options.receiveDataWhenStatusError,
            receiveTimeout: options.receiveTimeout,
            requestEncoder: options.requestEncoder,
            responseDecoder: options.responseDecoder,
            responseType: options.responseType,
            sendTimeout: options.sendTimeout,
            validateStatus: options.validateStatus);
        if ("bearer $accessToken" != options.headers["authorization"]) {
          options.headers["authorization"] = "bearer $accessToken";
          handle.resolve(await dio.request(options.path, options: optionsDio));
          // return handle.next(dio.request(options.path));
        }
        dio.lock();
        dio.interceptors.responseLock.lock();
        dio.interceptors.errorLock.lock();

        String keycloakRealmAddress = String.fromEnvironment(
            'KEYCLOAK_REALM_ADDRESS',
            defaultValue: dotenv.env['KEYCLOAK_REALM_ADDRESS']!);
        final String? refreshToken = await storage.read(key: "refresh_token");

        try {
          final TokenResponse? result = await appAuth.token(TokenRequest(
              'boldo-patient', 'py.org.pti.boldo:/login',
              discoveryUrl:
                  '$keycloakRealmAddress/.well-known/openid-configuration',
              refreshToken: refreshToken,
              scopes: ['openid', 'offline_access']));
          await storage.write(key: "access_token", value: result!.accessToken);
          await storage.write(key: "refresh_token", value: result.refreshToken);
          accessToken = result.accessToken;
          dio.unlock();
          dio.interceptors.responseLock.unlock();
          dio.interceptors.errorLock.unlock();
          //retry request
          return handle
              .resolve(await dio.request(options.path, options: optionsDio));
        } catch (e) {
          print(e);
          dio.unlock();
          dio.interceptors.responseLock.unlock();
          dio.interceptors.errorLock.unlock();
          await storage.deleteAll();
          accessToken = null;

          navKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HeroScreenV2(),
            ),
            (route) => false,
          );
          return handle.next(error);
        }
      }
      ConnectionStatusSingleton connectionStatus =
          ConnectionStatusSingleton.getInstance();
      bool hasInternet = await connectionStatus.checkConnection();
      if (!hasInternet) {
        navKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => const OfflineScreen(),
          ),
        );
      }
      return handle.next(error);
    },
  ));
}

void initDioSecondaryAccess({required GlobalKey<NavigatorState> navKey}) {
  String baseUrl = String.fromEnvironment('HEALTH_PTI_API',
      defaultValue: dotenv.env['HEALTH_PTI_API']!);

  dioHealthCore.options.baseUrl = baseUrl;
  dioHealthCore.options.headers['content-Type'] = 'application/json';
  dioHealthCore.options.headers['accept'] = 'application/json';
  // dioHealthCore.options.connectTimeout = 5000; //5s
  // dioHealthCore.options.receiveTimeout = 3000;
  String? accessToken;
  FlutterAppAuth appAuth = FlutterAppAuth();
  //setup interceptors

  dioHealthCore.interceptors.add(QueuedInterceptorsWrapper(
    onRequest: (options, handler) async {
      accessToken = (await storage.read(key: "access_token"))!;
      options.headers["authorization"] = "bearer $accessToken";

      return handler.next(options);
    },
    onError: (DioError error, handle) async {
      if (error.response?.statusCode == 403) {
        try {
          await storage.deleteAll();
          navKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(setLoggedOut: true),
            ),
            (route) => false,
          );
          // ignore: null_check_always_fails
          accessToken = null!;
        } catch (e) {
          print(e);
        }
      } else if (error.response?.statusCode == 401) {
        print("401 DIOHealtcore");
        if (accessToken == null) {
          await storage.deleteAll();

          return handle.next(error);
        }

        RequestOptions options = error.response!.requestOptions;
        Options optionsDio = Options(
            contentType: options.contentType,
            followRedirects: options.followRedirects,
            extra: options.extra,
            headers: options.headers,
            listFormat: options.listFormat,
            maxRedirects: options.maxRedirects,
            method: options.method,
            receiveDataWhenStatusError: options.receiveDataWhenStatusError,
            receiveTimeout: options.receiveTimeout,
            requestEncoder: options.requestEncoder,
            responseDecoder: options.responseDecoder,
            responseType: options.responseType,
            sendTimeout: options.sendTimeout,
            validateStatus: options.validateStatus);
        if ("bearer $accessToken" != options.headers["authorization"]) {
          options.headers["authorization"] = "bearer $accessToken";
          handle.resolve(await dio.request(options.path, options: optionsDio));
        }
        dio.lock();
        dio.interceptors.responseLock.lock();
        dio.interceptors.errorLock.lock();

        String keycloakRealmAddress = String.fromEnvironment(
            'KEYCLOAK_REALM_ADDRESS',
            defaultValue: dotenv.env['KEYCLOAK_REALM_ADDRESS']!);
        final String? refreshToken = await storage.read(key: "refresh_token");

        try {
          final TokenResponse? result = await appAuth.token(TokenRequest(
              'boldo-patient', 'py.org.pti.boldo:/login',
              discoveryUrl:
                  '$keycloakRealmAddress/.well-known/openid-configuration',
              refreshToken: refreshToken,
              scopes: ['openid', 'offline_access']));
          await storage.write(key: "access_token", value: result!.accessToken);
          await storage.write(key: "refresh_token", value: result.refreshToken);
          accessToken = result.accessToken;
          dio.unlock();
          dio.interceptors.responseLock.unlock();
          dio.interceptors.errorLock.unlock();
          return handle
              .resolve(await dio.request(options.path, options: optionsDio));
        } catch (e) {
          dio.unlock();
          dio.interceptors.responseLock.unlock();
          dio.interceptors.errorLock.unlock();
          await storage.deleteAll();
          accessToken = null;

          navKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(setLoggedOut: true),
            ),
            (route) => false,
          );
          return handle.next(error);
        }
      }
      ConnectionStatusSingleton connectionStatus =
          ConnectionStatusSingleton.getInstance();
      bool hasInternet = await connectionStatus.checkConnection();
      if (!hasInternet) {
        navKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => const OfflineScreen(),
          ),
        );
      }
      return handle.next(error);
    },
  ));
}
