import 'package:boldo/main.dart';
import 'package:boldo/models/Patient.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> setUser(Patient patient) async{
  SentryUser sentryUser;
  await Sentry.configureScope(
    (scope) async => {

      sentryUser = SentryUser(
        id: patient.id,
        username: patient.identifier,
      ),

      scope.setUser(sentryUser),

      scope.setTag('access_token',  await storage.read(key: 'access_token')?? ''),
    }
  );

}

Future<void> removeUser() async{
  await Sentry.configureScope((scope) => {
    scope.setUser(null),
    scope.removeTag("access_token")
  });
}