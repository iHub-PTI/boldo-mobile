import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/dashboard/tabs/components/item_menu.dart';
import 'package:boldo/screens/family/components/family_rectagle_card.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boldo/network/http.dart';
import 'package:boldo/provider/utils_provider.dart';

import 'package:boldo/screens/dashboard/tabs/doctors_tab.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/constants.dart';

class FamilyScreen extends StatefulWidget {
  final bool setLoggedOut;

  FamilyScreen({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _FamilyScreenState createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {

  final List<ItemMenu> items = [
  ];

  Response? response;
  bool _dataLoading = true;

  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  Future _getProfileData() async {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
    if (!isAuthenticated) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    response = await dio.get("/profile/patient");
    setState(() {
      _dataLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.setLoggedOut) {
      Future.microtask(() => Provider.of<AuthProvider>(context, listen: false)
          .setAuthenticated(isAuthenticated: false));
    }
    _getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            const Background(text: "family"),
            SafeArea(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon: SvgPicture.asset(
                              'assets/icon/chevron-left.svg',
                              color: ConstantsV2.activeText,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all( 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Mi Familia",
                            style: boldoTitleBlackTextStyle,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              child :Column(
                                  children: [
                                    const FamilyRectangleCard(isDependent: false)

                                  ]
                              )
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.topLeft,
                            child: items.length > 0 ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: items.length,
                              padding: const EdgeInsets.all(8),
                              scrollDirection: Axis.vertical,
                              itemBuilder: _buildItem,
                            ) : EmptyStateV2(picture: "Helping old man 1.svg", textBottom: "aún no agregaste ningún perfil para gestionar",),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  UtilsProvider().logout(context);
                                },
                                icon: SvgPicture.asset(
                                  "assets/icon/power-settings-new.svg",
                                  color: ConstantsV2.lightest,
                                ),
                                label: Text(
                                  "Cerrrar Sesión",
                                  style: boldoSubTextStyle.copyWith(
                                    color: ConstantsV2.lightest,
                                  ),
                                ),
                              ),
                            ]
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index){
    return items[index];
  }

}
