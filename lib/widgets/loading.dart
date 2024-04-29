import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

Widget loadingStatus({
  double? value,
  bool center = true,
}) {
  final progress = CircularProgressIndicator.adaptive(
    value: value,
    valueColor: const AlwaysStoppedAnimation<Color>(
      Constants.primaryColor400,
    ),
  );
  return center
      ? Center(
          child: progress,
        )
      : progress;
}
