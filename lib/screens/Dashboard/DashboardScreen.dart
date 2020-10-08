import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openid_client/openid_client_io.dart' as oidc;
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    String keyCloakAddress = DotEnv().env['KEYCLOAK_ADDRESS'];
    String serverAddress = DotEnv().env['SERVER_ADDRESS'];

    var authorizationEndPoint = "$keyCloakAddress/auth/realms/PTI-Health/";
    var clientId = "boldo-patient";

    oidc.Credential credential;

    var issuer = await oidc.Issuer.discover(Uri.parse(authorizationEndPoint));
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
      Response response =
          await Dio().post("$serverAddress/api/auth/code", data: {
        "tokenData": responseData,
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
      appBar: AppBar(
        titleSpacing: 12,
        backgroundColor: Colors.white,
        leading: Padding(
            padding: EdgeInsets.only(left: 18),
            child: SvgPicture.asset('assets/Logo.svg',
                semanticsLabel: 'BOLDO Logo')),
      ),
      body: getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: 'Doctors',
          ),
          !_authenticated
              ? BottomNavigationBarItem(
                  icon: Icon(
                    Icons.login,
                    size: 30,
                  ),
                  label: 'Authenticate',
                )
              : BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings,
                    size: 30,
                  ),
                  label: 'Settings',
                ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
      ),
    );
  }
}
