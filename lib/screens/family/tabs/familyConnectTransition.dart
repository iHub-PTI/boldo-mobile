import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:boldo/constants.dart';

import '../../../main.dart';

class FamilyConnectTransition extends StatefulWidget {
  final String? identifier;

  FamilyConnectTransition({Key? key, this.identifier }) : super(key: key);

  @override
  _FamilyConnectTransitionTransitionState createState() => _FamilyConnectTransitionTransitionState();
}

class _FamilyConnectTransitionTransitionState extends State<FamilyConnectTransition> {

  Patient? dependentPhoto;
  Response? response;
  bool _dataLoading = false;
  Widget _background = const Background(text: "FamilyConnect_1");
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();


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
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                                              _dataLoading ? Text("", style: boldoBillboardTextStyleAlt.copyWith(
                                                  color: ConstantsV2.lightGrey
                                              )) :Flexible(child:Text(
                                                "${user.givenName ?? ''}${user.familyName ?? ''}",
                                                textAlign: TextAlign.center,
                                                style: boldoBillboardTextStyleAlt.copyWith(
                                                    color: ConstantsV2.lightGrey,
                                                ),
                                              )),
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
