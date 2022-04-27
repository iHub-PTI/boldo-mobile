import 'package:boldo/models/Patient.dart';
import 'package:boldo/provider/user_provider.dart';
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

class FamilyConnectTransition extends StatefulWidget {
  final bool setLoggedOut;

  FamilyConnectTransition({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _FamilyConnectTransitionTransitionState createState() => _FamilyConnectTransitionTransitionState();
}

class _FamilyConnectTransitionTransitionState extends State<FamilyConnectTransition> {

  Patient? dependent;
  Response? response;
  bool _dataLoading = true;
  Widget _background = const Background(text: "FamilyConnect_1");
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  Future _getDependentDniInfo() async {
    dependent = Patient(
      givenName: "Fidel",
      familyName: "Aguirre",
      gender: "unknown",
      identifier: "1233445",
      photoUrl: "https://s3-alpha-sig.figma.com/img/9210/fd70/99decdd7aa6b9bf23fff1bc150449738?Expires=1652054400&Signature=ABbH0Fzwd4OhVen3MNLsqhhUrmIkDJ9vJ-i5eOPfTKfBJyXx8LAQQL3jviRhUR1Ncu8pEYKaTAJ8csylZCSIEOTzUDmey2u7-VXygECH9QE-C34VVLJEQK5hCalSLAuq469nZ3TaNkTODmFDCHIbhgMQW9wgswoDg4cal3pBD0cSohGi8frnkergVupuf89wmICfMOsfv4KcLCH6ewy4WJDF00yaH7948uQU8W8jKjhf3EcRSNg6hcY2z0RHnzaL-vQqPwBgjHQuRkopzSyZvzlgtfLTrfBJXKQ~wIPCYWReUxsNshP5gYwkCa0BaO5RAp0ABp4YBvJzhE5oWRDuJQ__&Key-Pair-Id=APKAINTVSUGEWH5XD5UA",
    );
  }

  Future<void> timer() async {
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _background = const Background(text: "FamilyConnect_2");
    });
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
  }

  Future _getProfileData() async {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
    if (!isAuthenticated) return;


  }

  @override
  void initState() {
    _getDependentDniInfo();
    timer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            _background,
            SafeArea(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        ProfileImageView2(height: 170, width: 170, border: true, patient: dependent,),
                                      ],
                                    ),
                                    const SizedBox(height: 29,),
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "agregando a",
                                                style: boldoSubTextStyle.copyWith(
                                                    color: ConstantsV2.lightGrey
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${dependent!.givenName} ${dependent!.familyName}",
                                                style: boldoBillboardTextStyleAlt.copyWith(
                                                    color: ConstantsV2.lightGrey
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                              )
                          ),
                        ],
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

}
