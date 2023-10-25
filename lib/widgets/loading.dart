import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

Widget loadingStatus(){
  return const Center(
      child: CircularProgressIndicator(
        valueColor:
        AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
        backgroundColor: Constants.primaryColor600,
      )
  );
}