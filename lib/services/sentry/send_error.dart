import 'package:boldo/main.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future <void> sendSentryError({
  required dynamic exception,
  StackTrace? stackTrace,
  Map<String, String>? tags,
}) async{
  Sentry.captureException(
    exception,
    stackTrace: stackTrace,
    withScope: (scope) async {
      tags?.forEach((key, value) {
        scope.setTag(key, value);
      });
    }
  );
}