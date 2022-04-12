import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/dashboard/dashboard_screen.dart';
import 'package:boldo/screens/hero/hero_screen.dart';
import 'package:boldo/screens/hero/hero_screen_v2.dart';
import 'package:boldo/screens/pre_register_notify/pre_register_success_screen.dart';
import 'package:boldo/screens/sing_in/sing_in_transition.dart';
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
    final _result = await authenticateUser(context: context);
    switch (_result) {
      case 0:
        Provider.of<UtilsProvider>(context, listen: false).logout(context);
        //user canceled or generic error
        Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (Route<dynamic> route) => false);
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
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SingInTransition(
              )
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        break;
      default:
    }
  }
}

Future<int> authenticateUser({required BuildContext context}) async {
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
    print("DATOS ${response.data}");
    await prefs.setString("profile_url", response.data["photoUrl"] ?? '');
    await prefs.setString("gender", response.data["gender"]);
    await prefs.setString("name", response.data["givenName"]);

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUserData(
      givenName: response.data['givenName'],
      familyName: response.data['familyName'],
      gender: response.data['gender'],
      photoUrl: response.data['photoUrl'],
      email: response.data['email'],
      birthDate: response.data['birthDate'],
      street: response.data['street'],
      city: response.data['city'],
    );

    print("FAMILY ${Provider.of<AuthProvider>(context, listen: false).getIsFamily}");

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
