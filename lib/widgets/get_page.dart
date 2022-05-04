

import 'package:boldo/screens/dashboard/dashboard_screen.dart';
import 'package:boldo/screens/dashboard/tabs/doctors_tab.dart';
import 'package:boldo/screens/dashboard/tabs/home_tab.dart';
import 'package:boldo/screens/dashboard/tabs/settings_tab.dart';
import 'package:boldo/screens/medical_records/medical_records_screen.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class GetPage{
  Widget getPage(int index, context) {

    if (index == 0) {
      return HomeTab();
    }
    if (index == 1) {
      return DoctorsTab();
    }
    if (index == 2) {
      return MedicalRecordScreen();
    }
    if (index == 3) {
      return SettingsTab();
    }
    return HomeTab();
  }
}