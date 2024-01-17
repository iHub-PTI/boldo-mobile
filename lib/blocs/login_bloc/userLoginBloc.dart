import 'package:boldo/environment.dart';
import 'package:boldo/main.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/pre_register_notify/pre_register_success_screen.dart';
import 'package:boldo/utils/errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'userLoginEvent.dart';
part 'userLoginState.dart';


class UserLoginBloc extends Bloc<UserLoginEvent, UserLoginState> {
  UserLoginBloc() : super(UserLoginInitial()){

    on<UserLoginEvent>((event, emit) async {
      if (event is UserLogin) {
        emit(UserLoginLoading());

        await redirectSignIn(
          context: event.context,
        );

        Navigator.pushNamed(
          event.context,
          '/SignInSuccess',
        );

        emit(UserLoginSuccess());
      }
    });
  }

  static Future<AuthorizationTokenResponse?> getToken() async {

    String keycloakRealmAddress = environment.KEYCLOAK_REALM_ADDRESS;

    FlutterAppAuth appAuth = const FlutterAppAuth();

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

    return result;
  }

  static Future<bool> redirectSignIn({ required BuildContext context }) async {
    try{

      AuthorizationTokenResponse? tokenResponse = await getToken();

      await storage.write(key: "access_token", value: tokenResponse?.accessToken);
      await storage.write(key: "refresh_token", value: tokenResponse?.refreshToken);

      return true;

    } on PlatformException catch (exception, stackTrace) {
      if (exception.message!.contains('User disabled')) {
        // pop signIn screen
        Navigator.pop(context);

        // redirect to Preregister screen
        Navigator.push(
          navKey.currentState?.context?? context,
          MaterialPageRoute(builder: (context) => const PreRegisterSuccess()),
        );

        return false;
      }
      if (!exception.message!.contains('User cancelled flow')) {
        print(exception);
        captureError(
          exception: exception,
          stackTrace: stackTrace,
        );
      }
      UserRepository().logout(context);
      //user canceled or generic error
      return false;
    } on Exception catch (exception, stackTrace) {
      print(exception);
      captureError(
        exception: exception,
        stackTrace: stackTrace,
      );
      UserRepository().logout(context);
      return false;
    }
  }

}