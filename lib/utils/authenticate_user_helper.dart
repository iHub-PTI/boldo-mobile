import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/pre_register_notify/pre_register_success_screen.dart';
import 'package:boldo/screens/sing_in/sing_in_transition.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../main.dart';
import 'helpers.dart';

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
    print("Result $_result");
    switch (_result) {
      case 0:
        UserRepository().logout(context);
        //user canceled or generic error
        Navigator.of(context)
            .popUntil(ModalRoute.withName("/onboarding"));
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
        selectedPageIndex = 0;
        Navigator.pushNamed(context, '/SignInSuccess');
        break;
      default:
    }
  }
}

Future<int> authenticateUser({required BuildContext context}) async {
  String keycloakRealmAddress = String.fromEnvironment('KEYCLOAK_REALM_ADDRESS',
      defaultValue: dotenv.env['KEYCLOAK_REALM_ADDRESS']!);

  FlutterAppAuth appAuth = FlutterAppAuth();

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

    await prefs.setBool("isLogged", true);
    await prefs.setBool("onboardingCompleted", true);

    Response response = await dio.get("/profile/patient");
    print("DATOS ${response.data}");
    await prefs.setString("profile_url", response.data["photoUrl"] ?? '');
    await prefs.setString("gender", response.data["gender"]);
    await prefs.setString("name", response.data['givenName']!= null ? toLowerCase(response.data['givenName']!) : '');
    await prefs.setString("lastName", response.data['familyName']!= null ? toLowerCase(response.data['familyName']!) : '');
    await prefs.setBool("isFamily", false);
    /*
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
      identifier: response.data['identifier'],
      id: response.data['id'],
    );

    print("FAMILY ${Provider.of<AuthProvider>(context, listen: false).getIsFamily}");
    */
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
