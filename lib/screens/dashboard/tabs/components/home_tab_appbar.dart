import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';

import '../../menu.dart';

class HomeTabAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double max;
  const HomeTabAppBar({
    Key? key,
    required this.max,
  }) : super(key: key);

  @override
  _HomeTabAppBarState createState() => _HomeTabAppBarState(max);
  @override
  Size get preferredSize => const Size.fromHeight(110);
}

class _HomeTabAppBarState extends State<HomeTabAppBar> {

  _HomeTabAppBarState(this.max);
  double max;
  Response? response;
  bool _dataLoading = true;
  var expanded = true ;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  Future _getProfileData() async {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
    if (!isAuthenticated) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Response response = await dio.get("/profile/patient");
    print("DATOS ${response.data}");
    await prefs.setString("profile_url", response.data["photoUrl"] ?? '');
    await prefs.setString("gender", response.data["gender"]);
    await prefs.setString("name", response.data["givenName"]);

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUserData(
        givenName: response.data['givenName'],
        familyName: response.data['familyName'],
        gender: response.data['gender'],
        photoUrl: response.data['photoUrl'],
        email: response.data['email'],
        birthDate: response.data['birthDate'],
        street: response.data['street'],
        city: response.data['city'],
        identifier: response.data['identifier']
    );
    setState(() {
      _dataLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
    expanded = widget.max > (ConstantsV2.homeAppBarMaxHeight+ConstantsV2.homeAppBarMinHeight)/2;
    return Container(
      constraints: BoxConstraints(maxHeight: widget.max, minHeight: widget.max),
      height: widget.max,
      decoration: _decoration(),
      child: Row(
        children: [
          const SizedBox(width: 10),
          ProfileImageView(height: expanded ? 100 : 60, width: expanded ? 100 : 60, border: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen()));
                        },
                        icon: SvgPicture.asset(
                          'assets/icon/menu-alt-1.svg',
                          color: ConstantsV2.lightest,
                        ),
                      )
                    ],
                  ),
                ),
                Selector<UserProvider, String>(
                    builder: (_, name, __){
                      return Text(
                        name,
                        style: boldoCardHeadingTextStyle.copyWith(
                            color: ConstantsV2.lightest
                        ),
                      );
                    },
                    selector: (buildContext, userProvider) =>
                    "${userProvider.getGivenName ?? ''} ${userProvider.getFamilyName ?? ''}",
                ),

                const SizedBox(height: 10),
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:[
                          Text(
                            data,
                            style: expanded ? boldoCorpMediumTextStyle : boldoCorpSmallTextStyle,
                          ),
                        ]
                    );
                  },
                  selector: (buildContext, userProvider) =>
                  userProvider.getCity ?? '',
                ),

                const SizedBox(height: 4),
                Text(
                  formatDate(
                    DateTime.now(),
                    [d, ' de ', MM, ' de ', yyyy],
                    locale: const SpanishDateLocale(),
                  ),
                  style: expanded ? boldoCorpMediumTextStyle : boldoCorpSmallTextStyle,
                ),
              ],
            ),
          ),
        ],

      ),
    );
  }

  BoxDecoration _decoration(){
    if(Provider.of<AuthProvider>(context, listen: false).getIsFamily){
      return const BoxDecoration(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
          gradient: RadialGradient(
              radius: 4,
              center: Alignment(
                1.80,
                0.77,
              ),
              colors: <Color>[
                ConstantsV2.patientAppBarColor100,
                ConstantsV2.patientAppBarColor200,
                ConstantsV2.patientAppBarColor300,
              ],
              stops: <double>[
                ConstantsV2.patientAppBarStop100,
                ConstantsV2.patientAppBarStop200,
                ConstantsV2.patientAppBarStop300,
              ]
          )
      );
    }else{
      return const BoxDecoration(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
          gradient: RadialGradient(
              radius: 4,
              center: Alignment(
                1.80,
                0.77,
              ),
              colors: <Color>[
                ConstantsV2.patientAppBarColor100,
                ConstantsV2.patientAppBarColor200,
                ConstantsV2.patientAppBarColor300,
              ],
              stops: <double>[
                ConstantsV2.patientAppBarStop100,
                ConstantsV2.patientAppBarStop200,
                ConstantsV2.patientAppBarStop300,
              ]
          )
      );
    }
  }

}
