import 'package:boldo/models/Patient.dart';
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

class DefinedRelationshipScreen extends StatefulWidget {
  final bool setLoggedOut;

  DefinedRelationshipScreen({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _DefinedRelationshipScreenState createState() => _DefinedRelationshipScreenState();
}

class _DefinedRelationshipScreenState extends State<DefinedRelationshipScreen> {

  late List<String> items = [];

  Response? response;
  bool _dataLoading = true;
  Patient? dependent;
  bool selected = false;
  String? relationship;

  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  Future _getFamiliesRelationship() async {

    items = ["Papá", "Mamá", "Hijo", "Hija", "Abuelo", "Abuela", "Nieto", "Nieta"];

    //response = await dio.get("/profile/patient");
  }

  Future _getDependentDniInfo() async {
    dependent = Patient(
      givenName: "Fidel",
      familyName: "Aguirre",
      gender: "unknown",
      identifier: "1233445",
    );
  }

  @override
  void initState() {
    super.initState();

    _getFamiliesRelationship();
    _getDependentDniInfo();

    setState(() {
      _dataLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            const Background(text: "linkFamily"),
            SafeArea(
              child: Container(
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
                                        ProfileImageView2(height: 100, width: 100, border: true, patient: dependent),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          !_dataLoading ? dependent!.givenName! + " " + dependent!.familyName! : '',
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
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: DropdownButton<String>(
                                value: relationship,
                                hint: Text(
                                  "¿Cuál es su relación con esta persona?",
                                  style: boldoSubTextMediumStyle.copyWith(
                                      color: ConstantsV2.activeText
                                  ),
                                ),
                                dropdownColor: ConstantsV2.lightGrey.withOpacity(0.5),
                                style: boldoSubTextMediumStyle.copyWith(color: Colors.black),
                                onChanged: (value) => setState(() {
                                  relationship = value!;
                                }),
                                items: items
                                    .map((relationship) => DropdownMenuItem<String>(
                                  child: Text(relationship),
                                  value: relationship,
                                )).toList(),
                                isExpanded: true,

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil(ModalRoute.withName("/methods"));
                              },
                              child: const Text(
                                "desvincular",
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


}
