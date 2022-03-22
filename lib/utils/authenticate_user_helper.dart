import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/dashboard/dashboard_screen.dart';
import 'package:boldo/screens/hero/hero_screen.dart';
import 'package:boldo/screens/hero/hero_screen_v2.dart';
import 'package:boldo/screens/pre_register_notify/pre_register_success_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class LoginWebViewHelper extends StatefulWidget {
  const LoginWebViewHelper({Key? key}) : super(key: key);

  @override
  _LoginWebViewHelperState createState() => _LoginWebViewHelperState();
}

class _LoginWebViewHelperState extends State<LoginWebViewHelper> {
  @override
  @override
  Widget build(BuildContext context) {
    _initWebView(context);
    return Container(
      color: Constants.grayColor50,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
          backgroundColor: Constants.primaryColor600,
        ),
      ),
    );
  }

  void _initWebView(context) async {
    final _result = await _authenticateUser(context: context);
    switch (_result) {
      case 0:
        //user canceled or generic error
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HeroScreenV2()),
        );
        break;
      case 1:
        //new user register
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PreRegisterSuccess()),
        );
        break;

      case 2:
        // success login
        Provider.of<UtilsProvider>(context, listen: false)
            .setSelectedPageIndex(pageIndex: 0);
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: "/home"),
            builder: (context) => DashboardScreen(),
          ),
        );
        break;
      default:
    }
  }
}

Future<int> _authenticateUser({required BuildContext context}) async {
  String keycloakRealmAddress = String.fromEnvironment('KEYCLOAK_REALM_ADDRESS',
      defaultValue: dotenv.env['KEYCLOAK_REALM_ADDRESS']!);

  FlutterAppAuth appAuth = FlutterAppAuth();

  const storage = FlutterSecureStorage();
  try {
    final AuthorizationTokenResponse? result =
        await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        'boldo-patient',
        'py.org.pti.boldo:/login',
        discoveryUrl: '$keycloakRealmAddress/.well-known/openid-configuration',
        scopes: ['openid', 'offline_access'],
        allowInsecureConnections: true,
      ),
    );

    await storage.write(key: "access_token", value: result!.accessToken);
    await storage.write(key: "refresh_token", value: result.refreshToken);

    Provider.of<AuthProvider>(context, listen: false)
        .setAuthenticated(isAuthenticated: true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboardingCompleted", true);

    Response response = await dio.get("/profile/patient");
    if (response.data["photoUrl"] != null) {
      await prefs.setString("profile_url", response.data["photoUrl"]);
      await prefs.setString("gender", response.data["gender"]);
      await prefs.setString("name", response.data["givenName"]);
    }

    return 2;
  } on PlatformException catch (err, s) {
    if (err.message!.contains('User disabled')) {
      return 1;
    }
    if (!err.message!.contains('User cancelled flow')) {
      print(err);
      await Sentry.captureException(err, stackTrace: s);
    }
  } catch (err, s) {
    print(err);
    await Sentry.captureException(err, stackTrace: s);
  }
  return 0;
}
