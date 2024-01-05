import 'package:boldo/app_config.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/environment.dart';
import 'package:boldo/network/connection_status.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/hero/hero_screen_v2.dart';
import 'package:boldo/screens/pre_register_notify/pre_register_success_screen.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../main.dart';
import '../screens/offline/offline_screen.dart';

var dio = Dio();
Map<String, dynamic> dioHeader = {
  'content-Type': 'application/json',
  'accept': 'application/json',
};
var dioPassport = Dio();
var dioDownloader = Dio();
var dioBCM = Dio();
var dioKC = Dio()..interceptors.add(QueuedInterceptorsWrapper(
  onRequest: (options, handler) async {

    try{
      FlutterAppAuth appAuth = const FlutterAppAuth();

      String keycloakRealmAddress = environment.KEYCLOAK_REALM_ADDRESS;
      final String? refreshToken = await storage.read(key: "refresh_token");

      final TokenResponse? result = await appAuth.token(TokenRequest(
        'boldo-patient',
        'py.org.pti.boldo:/login',
        discoveryUrl: '$keycloakRealmAddress/.well-known/openid-configuration',
        refreshToken: refreshToken,
        scopes: ['openid', 'offline_access'],
      ));

      await storage.write(key: "access_token", value: result!.accessToken);
      await storage.write(key: "refresh_token", value: result.refreshToken);

      Response response = Response(
        requestOptions: options,
        data: result,
      );

      handler.resolve(response);
    } catch (exception, stackTrace){

      DioException exceptionDio = DioException(
        requestOptions: options,
        error:  exception,
        stackTrace: stackTrace,
      );

      handler.reject(exceptionDio);
    }

  },
  onError: (dioException, handler){
    handler.next(dioException);
  },
));
void initDio(
    {required GlobalKey<NavigatorState> navKey,
      required Dio dio,
      String? baseUrl,
      ResponseType responseType = ResponseType.json,
      Map<String, dynamic>? header,
    }) {
  if(header != null) {
    dio.options.headers = header;
  }
  if(baseUrl != null) {
    dio.options.baseUrl = baseUrl;
  }
  dio.options.responseType = responseType;

  // limit time for download files
  if(responseType == ResponseType.bytes){
    int milliseconds = appConfig.RECIVE_TIMEOUT_MILLISECONDS_DOWNLOAD_FILES.getValue;
    dio.options.connectTimeout = const Duration(milliseconds: 1000*60);
    dio.options.receiveTimeout = Duration(milliseconds: milliseconds);
    appConfig.RECIVE_TIMEOUT_MILLISECONDS_DOWNLOAD_FILES.listenValue((value) =>
      dio.options.receiveTimeout = Duration(milliseconds: value)
    );
  }

  FlutterAppAuth appAuth = const FlutterAppAuth();

  ISentrySpan? transaction;

  //setup interceptors
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      String? accessToken = (await storage.read(key: "access_token") ?? '');
      options.headers["authorization"] = "bearer $accessToken";
      transaction = Sentry.startTransaction(
        options.path,
        options.method,
        bindToScope: true,
      );
      return handler.next(options);
    },
    onResponse: (response, handler){
      transaction?.finish(
        status: SpanStatus.fromHttpStatusCode(response.statusCode?? -1)
      );
      return handler.next(response);
    },
    onError: (DioError error, handle) async {
      String? accessToken = (await storage.read(key: "access_token") ?? '');
      if (error.response?.statusCode == 403) {
        try {
          await storage.deleteAll();
          // ignore: null_check_always_fails

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
        print("401 DIO");

        //check role permission
        try{
          // decode access token
          Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken?? '');

          //get roles list
          List<dynamic> roles = decodedToken['realm_access']['roles'];

          //check role patient
          if(!roles.contains('patient')){
            transaction?.throwable = error;
            transaction?.finish(
                status: SpanStatus.fromHttpStatusCode(error.response?.statusCode?? -1)
            );
            //return error 401
            return handle.next(error);
          }
        }on Exception catch (exception, stacktrace){
          captureError(
            exception: exception,
            stackTrace: stacktrace,
          );
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
          initDio(navKey: navKey, dio: _dio, baseUrl: baseUrl, header: header, responseType: responseType);
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
          initDio(navKey: navKey, dio: _dio, baseUrl: baseUrl, header: header, responseType: responseType);
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
                initDio(navKey: navKey, dio: _dio, baseUrl: baseUrl, header: header, responseType: responseType);
                return handle.resolve(await _dio.request(options.path,
                    data: options.data, options: optionsDio, queryParameters: options.queryParameters));
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
            transaction?.throwable = error;
            transaction?.finish(
                status: SpanStatus.fromHttpStatusCode(error.response?.statusCode?? -1)
            );
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
          transaction?.throwable = error;
          transaction?.finish(
              status: SpanStatus.fromHttpStatusCode(error.response?.statusCode?? -1)
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
        initDio(navKey: navKey, dio: _dio, baseUrl: baseUrl, header: header, responseType: responseType);
        return handle.resolve(await _dio.request(options.path,
            data: options.data, options: optionsDio, queryParameters: options.queryParameters));
      }
      transaction?.throwable = error;
      transaction?.finish(
        status: SpanStatus.fromHttpStatusCode(error.response?.statusCode?? -1)
      );
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
