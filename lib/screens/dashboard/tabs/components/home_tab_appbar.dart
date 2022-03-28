import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
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
  String? gender;
  String? profileURL;
  String? name;
  String? lastname;
  String? city;
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

    response = await dio.get("/profile/patient");
    name = response!.data["givenName"];
    lastname = response!.data["familyName"];
    city = response!.data["city"];
    profileURL = prefs.getString("profile_url")??'';
    gender = prefs.getString("gender");
    print("Ciudad $city");
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
      constraints: BoxConstraints(maxHeight: ConstantsV2.homeAppBarMaxHeight, minHeight: ConstantsV2.homeAppBarMinHeight),
      height: widget.max,
      decoration: const BoxDecoration(
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
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Selector<UserProvider, String>(
            builder: (_, data, __) {
              return SizedBox(
                height: expanded ? 100 : 60,
                width: expanded ? 100 : 60,
                child: Card(
                  margin: const EdgeInsets.all(0),
                  shape: const StadiumBorder(
                      side: BorderSide(
                        color: Colors.white,
                        width: 3,
                      )
                  ),
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child:
                    profileURL == null || profileURL == ''
                        ? SvgPicture.asset(
                      isAuthenticated
                          ? gender == "female"
                          ? 'assets/images/femalePatient.svg'
                          : 'assets/images/malePatient.svg'
                          : 'assets/images/LogoIcon.svg',
                    )
                        : CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: data != ''? data: profileURL!,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                          Padding(
                            padding: const EdgeInsets.all(26.0),
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  Constants.primaryColor400),
                              backgroundColor:
                              Constants.primaryColor600,
                            ),
                          ),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
            selector: (buildContext, userProvider) =>
            userProvider.getPhotoUrl ?? '',
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                !_dataLoading ? name! + " " + lastname! : '',
                style: expanded ? boldoCardHeadingTextStyle : boldoCorpMediumBlackTextStyle,
              ),
              const SizedBox(height: 10),
              Text(
                !_dataLoading ? city != null ? city! : '' : '',
                style: expanded ? boldoCorpMediumTextStyle : boldoCorpSmallTextStyle,
              ),
              Text(
                formatDate(
                  DateTime.now(),
                  [d, ' de ', MM, ' de ', yyyy],
                  locale: const SpanishDateLocale(),
                ),
                style: expanded ? boldoCorpMediumTextStyle : boldoCorpSmallTextStyle,
              ),
            ],
          )
        ],
      ),
    );
  }
}
