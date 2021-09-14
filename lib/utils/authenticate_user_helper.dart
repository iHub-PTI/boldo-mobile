import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/screens/dashboard/dashboard_screen.dart';
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
  const LoginWebViewHelper({Key key}) : super(key: key);

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
    if (_result == false) {
      Navigator.pop(context);
    }
  }
}

Future<bool> _authenticateUser({@required BuildContext context}) async {
  String keycloakRealmAddress = String.fromEnvironment('KEYCLOAK_REALM_ADDRESS',
      defaultValue: DotEnv().env['KEYCLOAK_REALM_ADDRESS']);

  FlutterAppAuth appAuth = FlutterAppAuth();

  const storage = FlutterSecureStorage();
  try {
    final AuthorizationTokenResponse result =
        await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        'boldo-patient',
        'com.penguin.boldo:/login',
        discoveryUrl: '$keycloakRealmAddress/.well-known/openid-configuration',
        scopes: ['openid', 'offline_access'],
        allowInsecureConnections: true,
      ),
    );

    await storage.write(key: "access_token", value: result.accessToken);
    await storage.write(key: "refresh_token", value: result.refreshToken);

    Provider.of<AuthProvider>(context, listen: false)
        .setAuthenticated(isAuthenticated: true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboardingCompleted", true);
    
    Response response = await dio.get("/profile/patient");
    if (response.data["photoUrl"] != null) {
      //

      await prefs.setString("profile_url", response.data["photoUrl"]);
      await prefs.setString("gender", response.data["gender"]);
      await prefs.setString("name", response.data["givenName"]);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: "/home"),
        builder: (context) => DashboardScreen(),
      ),
    );
    return true;
  } on PlatformException catch (err, s) {
    if (!err.message.contains('User cancelled flow')) {
      print(err);
      await Sentry.captureException(err, stackTrace: s);
    }
  } catch (err, s) {
    // final snackBar = SnackBar(content: Text('Authenticaton Failed!'));
    // Scaffold.of(context).showSnackBar(snackBar);

    print(err);
    await Sentry.captureException(err, stackTrace: s);
  }
  return false;
}
