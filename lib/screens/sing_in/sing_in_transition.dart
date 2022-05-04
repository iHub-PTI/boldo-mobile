import 'package:boldo/network/user_repository.dart';
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

import '../../main.dart';

class SingInTransition extends StatefulWidget {
  final bool setLoggedOut;

  SingInTransition({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _SingInTransitionState createState() => _SingInTransitionState();
}

class _SingInTransitionState extends State<SingInTransition> {

  Response? response;
  bool _dataLoading = true;
  Widget _background = const Background(text: "SingIn_1");
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  Future<void> timer() async {
    if(prefs.getBool("isFamily")?? false)
      patient = (await UserRepository().getPatient(prefs.getString("idFamily")))!;
    else
      patient = (await UserRepository().getPatient(null))!;
    setState(() {
      _dataLoading = false;
      _background = const Background(text: "SingIn_2");
    });
    await UserRepository().getDependents();
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pushNamedAndRemoveUntil('/home', ModalRoute.withName('/onboarding'));
  }

  Future _getProfileData() async {


  }

  @override
  void initState() {
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
                                        const ProfileImageView(height: 170, width: 170, border: true),
                                      ],
                                    ),
                                    const SizedBox(height: 29,),
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                _dataLoading ? Text('Cargando',style: boldoSubTextStyle.copyWith(
                                                    color: ConstantsV2.lightGrey
                                                ),) :Text(
                                                patient.gender == "unknown" ?
                                                  "Bienvenido/a" :
                                                patient.gender == "male" ?
                                                  "Bienvenido" : "Bienvenida",
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
                                                patient.givenName ?? '',
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
