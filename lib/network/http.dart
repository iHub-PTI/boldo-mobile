import 'package:boldo/network/connection_status.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/hero/hero_screen_v2.dart';
import 'package:boldo/screens/pre_register_notify/pre_register_success_screen.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../main.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/offline/offline_screen.dart';

var dio = Dio();
void initDio({required GlobalKey<NavigatorState> navKey, required Dio dio}) {
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
      accessToken = (await storage.read(key: "access_token") ?? '');
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
          // New dio connection to handle new errors
          Dio _dio = Dio();
          initDio(navKey: navKey, dio: _dio);
          //retry request
          return handle.resolve(await _dio.request(options.path,
              data: options.data, options: optionsDio, queryParameters: options.queryParameters));
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
          // New dio connection to handle new errors
          Dio _dio = Dio();
          initDio(navKey: navKey, dio: _dio);
          //retry request
          return handle.resolve(await _dio.request(options.path,
              data: options.data, options: optionsDio, queryParameters: options.queryParameters));
        } on DioError catch(exception){
          if (exception.response?.statusCode == 401){
            final _result = await authenticateUser(context: navKey.currentState!.context);
            switch (_result) {
              case 0:
              //user canceled or generic error
                navKey.currentState!.pushNamedAndRemoveUntil(
                  "/onboarding",
                      (route) => false,
                );
                break;
              case 1:
              //new user register
                navKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const PreRegisterSuccess()),
                    (route) => false,
                );
                break;

              case 2:
                Dio _dio = Dio();
                initDio(navKey: navKey, dio: _dio);
                return handle.resolve(await _dio.request(options.path,
                    data: options.data, options: optionsDio, queryParameters: options.queryParameters));
                break;
              default:
            }
          }
          else{
            if(exception.response?.statusCode == 500) {
              accessToken = null;
              UserRepository().logout(navKey.currentState!.context);
              navKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HeroScreenV2(),
                ),
                    (route) => false,
              );
            }
            return handle.next(exception);
          }
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
        await navKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => const OfflineScreen(),
          ),
        );
        RequestOptions options = error.requestOptions;
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
        Dio _dio = Dio();
        initDio(navKey: navKey, dio: _dio);
        return handle.resolve(await _dio.request(options.path,
            data: options.data, options: optionsDio, queryParameters: options.queryParameters));
      }
      return handle.next(error);
    },
  ));
}
