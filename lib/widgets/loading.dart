import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

Widget loadingStatus({double? value}){
  return Center(
      child: CircularProgressIndicator.adaptive(
        value: value,
        valueColor:
        const AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
      ),
  );
}