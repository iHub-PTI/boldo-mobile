import 'dart:convert';

import 'package:boldo/main.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// The [stackTrace] will be attached at the end of the params
Future <void> sendSentryMessage({
  required String message,
  StackTrace? stackTrace,
  Map<String, dynamic>? params,
  Map<String, String>? tags,
}) async{
  Sentry.captureMessage(
    message,
    params: [
      jsonDecode(jsonEncode(params)),
      stackTrace,
    ],
    withScope: (scope) async {
      tags?.forEach((key, value) {
        scope.setTag(key, value);
      });
    }
  );
}