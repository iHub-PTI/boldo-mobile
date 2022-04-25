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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boldo/network/http.dart';
import 'package:boldo/provider/utils_provider.dart';

import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/constants.dart';

import 'QR_generator.dart';

class MyManagersTab extends StatefulWidget {
  final bool setLoggedOut;

  MyManagersTab({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _MyManagersTabState createState() => _MyManagersTabState();
}

class _MyManagersTabState extends State<MyManagersTab> {

  final List<Patient> items = [
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
            const Background(text: "family"),
            SafeArea(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: (){
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
                      margin: const EdgeInsets.all( 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Mis gestores",
                            style: boldoTitleBlackTextStyle,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.topLeft,
                            child: items.length > 0 ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: items.length,
                              padding: const EdgeInsets.all(8),
                              scrollDirection: Axis.vertical,
                              itemBuilder: _buildItem,
                            ) : const EmptyStateV2(picture: "Helping old man 1.svg", textBottom: "aún no tienes ningún gestor",),
                          ),
                        ],
                      ),
                    ),
                    items.length > 0 ? Container(): Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: const Text("Aquí apareceran las personas a quienes des "
                            "permiso como gestor. Esto significa que van a poder "
                            "ver tu historia clinica y realizar gestiones como "
                            "marcar y cancelar consultas en tu nombre, entre otras "
                            "funciones"),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => const QRGenerator()
                                      ));
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text("vincular con QR"),
                                        const SizedBox(width: 10,),
                                        SvgPicture.asset(
                                          'assets/icon/qrcode.svg',
                                          color: ConstantsV2.lightGrey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]
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
    return FamilyRectangleCard(patient: items[index], isDependent: true,);
  }

}
