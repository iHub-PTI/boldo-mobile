import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/User.dart';
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

import '../../../main.dart';
import 'defined_relationship_screen.dart';

class FamilyConnectTransition extends StatefulWidget {
  final String? identifier;

  FamilyConnectTransition({Key? key, this.identifier }) : super(key: key);

  @override
  _FamilyConnectTransitionTransitionState createState() => _FamilyConnectTransitionTransitionState();
}

class _FamilyConnectTransitionTransitionState extends State<FamilyConnectTransition> {

  User? dependent;
  Patient? dependentPhoto;
  Response? response;
  bool _dataLoading = true;
  Widget _background = const Background(text: "FamilyConnect_1");
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  Future _getDependentDniInfo() async {
    if(!user.isNew){
      String? code = user.identifier;
      print("IDENTIFICADOR ${user.identifier}");
      dependent = await UserRepository().getDependent(user.identifier!);

      user = dependent!;
    }else{
      dependent =  user;
    }
    _dataLoading = false;
    dependentPhoto = Patient(givenName: user.givenName, familyName: user.familyName, gender: user.gender);
  }

  Future<void> timer() async {
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _background = const Background(text: "FamilyConnect_2");
    });
    await UserRepository().getRelationships();
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushNamed(context, '/defineRelationship');
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
                                        ProfileImageView2(height: 170, width: 170, border: true, patient: dependentPhoto,),
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
                                              _dataLoading ? Text("cargando", style: boldoBillboardTextStyleAlt.copyWith(
                                                  color: ConstantsV2.lightGrey
                                              )) :Text(
                                                "${dependent!.givenName ?? ''} ${dependent!.familyName ?? ''}",
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
