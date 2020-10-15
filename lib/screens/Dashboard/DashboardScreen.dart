import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openid_client/openid_client_io.dart' as oidc;
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../constant.dart';
import './tabs/HomeTab.dart';
import './tabs/DoctorsTab.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _authenticated = false;
  _urlLauncher(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> authenticate() async {
    String keycloakRealmAddress = DotEnv().env['KEYCLOAK_REALM_ADDRESS'];
    String serverAddress = DotEnv().env['SERVER_ADDRESS'];

    var clientId = "boldo-patient";

    oidc.Credential credential;

    var issuer = await oidc.Issuer.discover(Uri.parse(keycloakRealmAddress));
    var client = new oidc.Client(issuer, clientId);
    //auth from browser
    var authenticator = oidc.Authenticator(
      client,
      scopes: List<String>.of(['openid', 'profile', 'offline_access']),
      urlLancher: _urlLauncher,
    );
    credential = await authenticator.authorize();
    closeWebView();

    //get token and send it to the server from here
    var responseData = await credential.getTokenResponse();
    try {
      Response response = await Dio().post("$serverAddress/code", data: {
        "accessToken": responseData.accessToken,
        "refreshToken": responseData.refreshToken,
      });
      setState(() {
        _authenticated = true;
      });
      print(response);
    } catch (e) {
      print(e);
    }
  }

  Widget getPage(int index) {
    if (index == 0) {
      return HomeTab();
    }
    if (index == 1) {
      return DoctorsTab();
    }
    if (index == 2) {
      authenticate();
      setState(() {
        _selectedIndex = 1;
      });
      return DoctorsTab();
    }
    return HomeTab();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/homeIcon.svg',
              semanticsLabel: 'Doctor Icon',
              color: _selectedIndex == 0
                  ? boldoDarkPrimaryColor
                  : boldoMainGrayColor,
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/doctorIcon.svg',
              semanticsLabel: 'Doctor Icon',
              color: _selectedIndex == 1
                  ? boldoDarkPrimaryColor
                  : boldoMainGrayColor,
            ),
            label: 'Médicos',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              !_authenticated
                  ? 'assets/icon/profileIcon.svg'
                  : 'assets/icon/settingsIcon.svg',
              semanticsLabel: 'Doctor Icon',
              color: _selectedIndex == 2
                  ? boldoDarkPrimaryColor
                  : boldoMainGrayColor,
            ),
            label: !_authenticated ? 'Authenticate' : "Settings",
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: boldoDarkPrimaryColor,
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
      ),
    );
  }
}
