import 'package:boldo/screens/medical_records/medical_records_screen.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boldo/network/http.dart';

import 'package:boldo/screens/dashboard/tabs/home_tab.dart';
import 'package:boldo/screens/dashboard/tabs/doctors_tab.dart';
import 'package:boldo/screens/dashboard/tabs/settings_tab.dart';
import 'package:boldo/constants.dart';

import '../../main.dart';

class DashboardScreen extends StatefulWidget {
  final bool setLoggedOut;

  DashboardScreen({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();

  }

  Widget getPage(int index) {



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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          key: scaffoldKey,
          body: getPage(selectedPageIndex),
          /*bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: false,
            items: <BottomNavigationBarItem>
              [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/homeIcon.svg',
                    semanticsLabel: 'Home Icon',
                    color: selectedPageIndex == 0
                        ? Constants.secondaryColor500
                        : Constants.extraColor200,
                  ),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/doctorIcon.svg',
                    semanticsLabel: 'Doctor Icon',
                    color: selectedPageIndex == 1
                        ? Constants.secondaryColor500
                        : Constants.extraColor200,
                  ),
                  label: 'Médicos',
                ),
                 BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/file.svg',
                    semanticsLabel: 'Ficha Icon',
                    color: selectedPageIndex == 2
                        ? Constants.secondaryColor500
                        : Constants.extraColor200,
                  ),
                  label: 'Mis Fichas',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/settingsIcon.svg',
                    semanticsLabel: 'Settings Icon',
                    color: selectedPageIndex == 3
                        ? Constants.secondaryColor500
                        : Constants.extraColor200,
                  ),
                  label: "Config",
                )
              ],
                currentIndex: selectedPageIndex,
                selectedItemColor: Constants.secondaryColor500,
                onTap: (index) {
                  selectedPageIndex = index;
                })*/
          ),
        );
  }
}
