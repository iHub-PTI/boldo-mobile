import 'package:boldo/constants.dart';
import 'package:boldo/environment.dart';
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
var dioPassport = Dio();
var dioDownloader = Dio();
void initDio(
    {required GlobalKey<NavigatorState> navKey,
    required Dio dio,
    required bool passport}) {
  String baseUrl = "";
  if (passport) {
    baseUrl = environment.SERVER_ADDRESS_PASSPORT;
  } else {
    baseUrl = environment.SERVER_ADDRESS;
        dio.options.headers['content-Type'] = 'application/json';
        dio.options.headers['accept'] = 'application/json';
  }

  dio.options.baseUrl = baseUrl;

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
          initDio(navKey: navKey, dio: _dio, passport: passport);
          //retry request
          return handle.resolve(await _dio.request(options.path,
              data: options.data, options: optionsDio, queryParameters: options.queryParameters));
        }

        String keycloakRealmAddress = environment.KEYCLOAK_REALM_ADDRESS;
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
          // New dio connection to handle new errors
          Dio _dio = Dio();
          initDio(navKey: navKey, dio: _dio, passport: passport);
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
                  MaterialPageRoute(
                      builder: (context) => const PreRegisterSuccess()),
                  (route) => false,
                );
                break;

              case 2:
                Dio _dio = Dio();
                initDio(navKey: navKey, dio: _dio, passport: passport);
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
        initDio(navKey: navKey, dio: _dio, passport: passport);
        return handle.resolve(await _dio.request(options.path,
            data: options.data, options: optionsDio, queryParameters: options.queryParameters));
      }
      return handle.next(error);
    },
  ));
}

Future<void> _showInternetFailedDialog() async {
  if (navKey.currentContext == null) {
    return;
  } else {
    return showDialog<void>(
      context: navKey.currentContext!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(
            Icons.wifi,
            color: Constants.extraColor200,
            size: 80,
          ),
          content: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Text(
                    "¿Sin internet?",
                    style: boldoHeadingTextStyle.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Al parecer hay un problema con \n tu conexión. Revisá el \n estado de tu internet para \n continuar.",
                  style: boldoSubTextStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void dioByteInstance() async {
  String baseUrl = environment.SERVER_ADDRESS_PASSPORT;
  dioDownloader.options.baseUrl = baseUrl;
  dioDownloader.options.connectTimeout = const Duration(milliseconds: 20000);
  dioDownloader.options.receiveTimeout = const Duration(milliseconds: 20000);
  dioDownloader.options.responseType = ResponseType.bytes;

  String? accessToken;
  FlutterAppAuth appAuth = FlutterAppAuth();

  //setup interceptors
  dioDownloader.interceptors.add(QueuedInterceptorsWrapper(
    onRequest: (options, handler) async {
      accessToken = (await storage.read(key: "access_token"))!;
      options.headers["authorization"] = "bearer $accessToken";

      return handler.next(options);
    },
    onError: (DioError error, handle) async {
      if (error.response?.statusCode == 403) {
        try {
          await storage.deleteAll();
          accessToken = null;

          navKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HeroScreenV2(),
            ),
            (route) => false,
          );
        } catch (e) {
          print(e);
        }
      } else if (error.response?.statusCode == 401) {
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
          handle.resolve(
              await dioDownloader.request(options.path, data: options.data, options: optionsDio, queryParameters: options.queryParameters));
        }
        String keycloakRealmAddress = environment.KEYCLOAK_REALM_ADDRESS;
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
          //retry request
          return handle.resolve(
              await dioDownloader.request(options.path, data: options.data, options: optionsDio, queryParameters: options.queryParameters));
        } catch (e) {
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
        _showInternetFailedDialog();
        // navKey.currentState!.push(
        //   MaterialPageRoute(
        //     builder: (context) => const OfflineScreen(),
        //   ),
        // );
      }
      return handle.next(error);
    },
  ));
}