import 'dart:io';

import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/dashboard/tabs/components/item_menu.dart';
import 'package:boldo/screens/privacy_policy/privacy_policy.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/screens/terms_of_services/terms_of_services.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:boldo/constants.dart';
import 'package:share_plus/share_plus.dart';

import '../../main.dart';

class MenuScreen extends StatefulWidget {
  final bool setLoggedOut;

  MenuScreen({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final List<Widget> items = [
    ItemMenu(
      image: 'assets/icon/share.svg',
      title: 'Recomendar Boldo',
      action: () async {
        // TODO: share message with image
        // TODO: change url with a
        File imageFile = await getImageFileFromAssets('share_picture.jpeg');
        final box = navKey.currentState!.context.findRenderObject() as RenderBox?;
        await Share.share(
          "Estoy usando Boldo, el ecosistema de productos digitales de salud del Paraguay. "
              "Descargalo gratis en: "
              "https://boldo-dev.pti.org.py/download",
          subject: 'Recomendar Boldo a un amigo',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      },
    ),
    ItemMenu(
      image: 'assets/icon/family.svg',
      title: 'Mi Familia',
      action: () {
        Navigator.pushNamed(navKey.currentState!.context, '/familyScreen');
      },
    ),
    ItemMenu(
      image: 'assets/icon/shield-check.svg',
      title: 'Polîticas de privacidad',
      action: (){
        Navigator.push(navKey.currentState!.context, MaterialPageRoute(
            builder: (context) => PrivacyPolicy()
        ),
        );
      },
    ),
    ItemMenu(
      image: 'assets/icon/document-text.svg',
      title: 'Términos de servicio',
      action: (){
        Navigator.push(navKey.currentState!.context, MaterialPageRoute(
            builder: (context) => TermsOfServices(),
        ),
        );
      },

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
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
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
