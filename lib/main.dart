import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import './network/http.dart';
import './provider/auth_provider.dart';
import './screens/Dashboard/DashboardScreen.dart';
import './screens/Hero/HeroScreen.dart';

import './size_config.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();
  Intl.defaultLocale = "es";
  await DotEnv().load('.env');
  GestureBinding.instance.resamplingEnabled = true;

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool("onboardingCompleted") ?? false;
  const storage = FlutterSecureStorage();
  String value = await storage.read(key: "access_token");

  String baseUrl = String.fromEnvironment('SERVER_ADDRESS',
      defaultValue: DotEnv().env['SERVER_ADDRESS']);

  dio.options.baseUrl = baseUrl;

  String accessToken;
  FlutterAppAuth appAuth = FlutterAppAuth();
  //setup interceptors
  dio.interceptors
      .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
    accessToken ??= await storage.read(key: "access_token");
    options.headers["authorization"] = "bearer $accessToken";

    return options;
  }, onError: (DioError error) async {
    if (error.response?.statusCode == 403) {
      try {
        await storage.deleteAll();
        accessToken = null;
        navKey.currentState.push(
          MaterialPageRoute(
            builder: (context) => DashboardScreen(setLoggedOut: true),
          ),
        );
      } catch (e) {
        print(e);
      }
    }
    if (error.response?.statusCode == 401) {
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
        await storage.write(key: "refresh_token", value: result.refreshToken);
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
        navKey.currentState.push(
          MaterialPageRoute(
            builder: (context) => DashboardScreen(setLoggedOut: true),
          ),
        );
        return error;
      }
    }
    return error;
  }));

  runApp(MyApp(
    onboardingCompleted: onboardingCompleted,
    session: value,
  ));
}

class MyApp extends StatefulWidget {
  final bool onboardingCompleted;
  final String session;
  const MyApp(
      {Key key, @required this.onboardingCompleted, @required this.session})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(widget.session != null ? true : false)),
      ],
      child: FullApp(onboardingCompleted: widget.onboardingCompleted),
    );
  }
}

class FullApp extends StatelessWidget {
  const FullApp({
    Key key,
    @required this.onboardingCompleted,
  }) : super(key: key);

  final bool onboardingCompleted;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      title: 'Boldo',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingScreen(onboardingCompleted: onboardingCompleted),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key key, @required this.onboardingCompleted})
      : super(key: key);
  final bool onboardingCompleted;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return onboardingCompleted ? DashboardScreen() : HeroScreen();
  }
}
