import 'package:boldo/provider/utils_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../constants.dart';
import 'tabs/home_tab.dart';
import 'tabs/doctors_tab.dart';
import 'tabs/settings_tab.dart';

class DashboardScreen extends StatefulWidget {
  final bool setLoggedOut;
  DashboardScreen({Key key, this.setLoggedOut = false}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Logger logger = Logger();
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.setLoggedOut) {
      Future.microtask(() => Provider.of<AuthProvider>(context, listen: false)
          .setAuthenticated(isAuthenticated: false));
    }
  }

  Future<void> authenticate() async {
    String keycloakRealmAddress = String.fromEnvironment(
        'KEYCLOAK_REALM_ADDRESS',
        defaultValue: DotEnv().env['KEYCLOAK_REALM_ADDRESS']);

    FlutterAppAuth appAuth = FlutterAppAuth();

    const storage = FlutterSecureStorage();
    try {
      final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          'boldo-patient',
          'com.penguin.boldo:/login',
          discoveryUrl:
              '$keycloakRealmAddress/.well-known/openid-configuration',
          scopes: ['openid', 'offline_access'],
          allowInsecureConnections: true,
        ),
      );
      logger.i("Logged In");
      await storage.write(key: "access_token", value: result.accessToken);
      await storage.write(key: "refresh_token", value: result.refreshToken);

      Provider.of<AuthProvider>(context, listen: false)
          .setAuthenticated(isAuthenticated: true);
    } catch (err) {
      // final snackBar = SnackBar(content: Text('Authenticaton Failed!'));
      // Scaffold.of(context).showSnackBar(snackBar);
      logger.e(err);
    }
    Provider.of<UtilsProvider>(context, listen: false)
        .setSelectedPageIndex(pageIndex: 0);
  }

  Widget getPage(int index) {
    if (index == 0) {
      return HomeTab();
    }
    if (index == 1) {
      return DoctorsTab();
    }
    if (index == 2) {
      bool isAuthenticated =
          Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
      if (!isAuthenticated) {
        authenticate();
        return const Center(child: CircularProgressIndicator());
      }

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
        child: Selector<UtilsProvider, int>(
          selector: (buildContext, userProvider) =>
              userProvider.getSelectedPageIndex,
          builder: (_, _selectedPageIndex, __) {
            return Scaffold(
              key: scaffoldKey,
              body: getPage(_selectedPageIndex),
              bottomNavigationBar:
                  Consumer<AuthProvider>(builder: (context, myInstance, child) {
                bool isAuthenticated = myInstance.getAuthenticated;
                return BottomNavigationBar(
                    showUnselectedLabels: false,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          'assets/icon/homeIcon.svg',
                          semanticsLabel: 'Doctor Icon',
                          color: _selectedPageIndex == 0
                              ? Constants.secondaryColor500
                              : Constants.extraColor200,
                        ),
                        label: 'Inicio',
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          'assets/icon/doctorIcon.svg',
                          semanticsLabel: 'Doctor Icon',
                          color: _selectedPageIndex == 1
                              ? Constants.secondaryColor500
                              : Constants.extraColor200,
                        ),
                        label: 'Médicos',
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          !isAuthenticated
                              ? 'assets/icon/profileIcon.svg'
                              : 'assets/icon/settingsIcon.svg',
                          semanticsLabel: 'Doctor Icon',
                          color: _selectedPageIndex == 2
                              ? Constants.secondaryColor500
                              : Constants.extraColor200,
                        ),
                        label: !isAuthenticated ? 'Cuenta' : "Config",
                      )
                    ],
                    currentIndex: _selectedPageIndex,
                    selectedItemColor: Constants.secondaryColor500,
                    onTap: (index) {
                      Provider.of<UtilsProvider>(context, listen: false)
                          .setSelectedPageIndex(pageIndex: index);
                    });
              }),
            );
          },
        ));
  }
}
