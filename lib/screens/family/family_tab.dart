import 'package:boldo/models/Patient.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/dashboard/tabs/components/item_menu.dart';
import 'package:boldo/screens/family/components/family_rectagle_card.dart';
import 'package:boldo/screens/family/tabs/metods_add_family_screen.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boldo/network/http.dart';

import 'package:boldo/constants.dart';

import '../../main.dart';

class FamilyScreen extends StatefulWidget {
  final bool setLoggedOut;

  FamilyScreen({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _FamilyScreenState createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  Future _getProfileData() async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        const Background(text: "family"),
        SafeArea(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
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
                  margin: const EdgeInsets.all(16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width-16,
                          child: Column(children: [
                        const FamilyRectangleCard(isDependent: false)
                      ])),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.55,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.topLeft,
                        child: families.length > 0
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: families.length,
                                padding: const EdgeInsets.all(8),
                                scrollDirection: Axis.vertical,
                                itemBuilder: _buildItem,
                              )
                            : const EmptyStateV2(
                                picture: "Helping old man 1.svg",
                                textBottom:
                                    "Aún no agregaste ningún perfil para gestionar",
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/methods');
                          },
                          child: Text(families.length > 0
                              ? "nuevo miembro"
                              : "agregar"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return FamilyRectangleCard(
      patient: families[index],
      isDependent: true,
    );
  }
}
