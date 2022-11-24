import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/dashboard/tabs/components/item_menu.dart';
import 'package:boldo/screens/privacy_policy/privacy_policy.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/screens/terms_of_services/terms_of_services.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:boldo/constants.dart';

import '../../main.dart';

class MenuScreen extends StatefulWidget {
  final bool setLoggedOut;

  MenuScreen({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final List<ItemMenu> items = [
    const ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Mi Familia',
      route: '/familyScreen',
    ),
    const ItemMenu(
      image: 'assets/icon/shield-check.svg',
      title: 'Polîticas de privacidad',
      page: PrivacyPolicy(),
    ),
    const ItemMenu(
      image: 'assets/icon/document-text.svg',
      title: 'Términos de servicio',
      page: TermsOfServices(),
    ),
    const ItemMenu(
      image: 'assets/icon/share.svg',
      title: 'Compartir',
      page: null,
    ),
    // const ItemMenu(
    //   image: 'assets/icon/adjustments.svg',
    //   title: 'Configuraciones',
    //   page: null,
    // ),
  ];

  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
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
                                              GestureDetector(
                                                onTap: (){
                                                  Navigator.pushNamed(context, '/profileScreen');
                                                },
                                                child: const ProfileImageView(height: 170, width: 170, border: true),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${patient.givenName??''} ${patient.familyName??''}",
                                                style: boldoTitleRegularTextStyle,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 30,),
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
                                    physics: const ClampingScrollPhysics(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextButton.icon(
                                  onPressed: () {
                                    UserRepository().logout(context);
                                  },
                                  icon: SvgPicture.asset(
                                    "assets/icon/power-settings-new.svg",
                                    color: ConstantsV2.yellow,
                                  ),
                                  label: Text(
                                    "Cerrar Sesión",
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
