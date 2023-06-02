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

class _FamilyConnectTransitionTransitionState extends State<FamilyConnectTransition> with SingleTickerProviderStateMixin {

  Patient? dependentPhoto;
  Response? response;
  bool _dataLoading = false;
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  // controller to animate background
  late AnimationController _colorController;


  Future<void> timer() async {
    await Future.delayed(const Duration(seconds: 3));
    //init animation
    _colorController.forward();
    await UserRepository().getRelationships();
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushNamed(context, '/defineRelationship');
  }

  @override
  void initState() {
    timer();
    // initialize animation duration
    _colorController = AnimationController(
        duration: const Duration(milliseconds: 1700),
        vsync: this
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            BackgroundRadialGradientTransition(
                initialColors: [ConstantsV2.familyConnectPrimaryColor100, ConstantsV2.familyConnectPrimaryColor200, ConstantsV2.familyConnectPrimaryColor300,],
                finalColors: [ConstantsV2.familyConnectSecondaryColor100, ConstantsV2.familyConnectSecondaryColor200, ConstantsV2.familyConnectSecondaryColor300,],
                initialStops: [ConstantsV2.familyConnectPrimaryStop100, ConstantsV2.familyConnectPrimaryStop200, ConstantsV2.familyConnectPrimaryStop300,],
                finalStops: [ConstantsV2.familyConnectSecondaryStop100, ConstantsV2.familyConnectSecondaryStop200, ConstantsV2.familyConnectSecondaryStop300,],
                initialRadius: .5,
                finalRadius: .6,
                animationController: _colorController
            ),
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
                                        ImageViewTypeForm(height: 170, width: 170, border: true, url: user.photoUrl, gender: user.gender,),
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
                                                "${user.givenName ?? ''} ${user.familyName ?? ''}",
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
