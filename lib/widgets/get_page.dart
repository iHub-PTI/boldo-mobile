import 'package:boldo/screens/appointments/pastAppointments_screen.dart';
import 'package:boldo/screens/dashboard/tabs/home_tab.dart';
import 'package:boldo/screens/dashboard/tabs/settings_tab.dart';
import 'package:boldo/screens/doctor_search/doctors_available.dart';
import 'package:flutter/material.dart';

class GetPage{
  Widget getPage(int index, context) {

    if (index == 0) {
      return HomeTab();
    }
    if (index == 1) {
      return DoctorsAvailable(callFromHome: true,);
    }
    if (index == 2) {
      return const PastAppointmentsScreen();
    }
    if (index == 3) {
      return SettingsTab();
    }
    return HomeTab();
  }
}