import 'package:boldo/screens/dashboard/tabs/components/item_menu.dart';
import 'package:boldo/screens/family/family_tab.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/screens/terms_of_services/terms_of_services.dart';
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
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/constants.dart';

class MenuScreen extends StatefulWidget {
  final bool setLoggedOut;

  MenuScreen({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final List<ItemMenu> items = [
    ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Mi Familia',
      page: FamilyScreen(),
    ),
    const ItemMenu(
      image: 'assets/icon/shield-check.svg',
      title: 'Politicas de privacidad',
      page: null,
    ),
    const ItemMenu(
      image: 'assets/icon/document-text.svg',
      title: 'Terminos de servicio',
      page: TermsOfServices(),
    ),
    const ItemMenu(
      image: 'assets/icon/adjustments.svg',
      title: 'Configuraciones',
      page: null,
    ),
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
          const Background(text: "menu"),
          SafeArea(
            child: Container(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: SvgPicture.asset(
                            'assets/icon/close.svg',
                            color: ConstantsV2.lightest,
                          ),
                        )
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const ProfileImageView(height: 170, width: 170, border: true),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    !_dataLoading ? response!.data["givenName"]! + " " + response!.data["familyName"]! : '',
                                    style: boldoTitleRegularTextStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40,),
                            ]
                          )
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: items.length,
                            padding: const EdgeInsets.all(16),
                            scrollDirection: Axis.vertical,
                            itemBuilder: _buildItem,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: TextButton.icon(
                          onPressed: () {
                           UtilsProvider().logout(context);
                          },
                          icon: SvgPicture.asset(
                            "assets/icon/power-settings-new.svg",
                            color: ConstantsV2.yellow,
                          ),
                          label: Text(
                            "Cerrrar Sesión",
                            style: boldoSubTextStyle.copyWith(
                              color: ConstantsV2.lightest,
                            ),
                          ),
                        ),
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
