import 'package:boldo/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTabAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeTabAppBar({
    Key? key,
  }) : super(key: key);

  @override
  _HomeTabAppBarState createState() => _HomeTabAppBarState();
  @override
  Size get preferredSize => const Size.fromHeight(110);
}

class _HomeTabAppBarState extends State<HomeTabAppBar> {
  String? gender;
  String? profileURL;

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

    profileURL = prefs.getString("profile_url");
    gender = prefs.getString("gender");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      leadingWidth: double.infinity,
      toolbarHeight: 110,
      flexibleSpace: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 30, left: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              Selector<UserProvider, String>(
                builder: (_, data, __) {
                  return SizedBox(
                    height: 60,
                    width: 60,
                    child: Card(
                      margin: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 9,
                      child: ClipOval(
                          clipBehavior: Clip.antiAlias,
                          child: SvgPicture.asset(
                            isAuthenticated
                                ? gender == "female"
                                    ? 'assets/images/femalePatient.svg'
                                    : 'assets/images/malePatient.svg'
                                : 'assets/images/LogoIcon.svg',
                          )
                          //FIXME when server img is available again
                          // data == null && profileURL == null
                          //     ? SvgPicture.asset(
                          //         isAuthenticated
                          //             ? gender == "female"
                          //                 ? 'assets/images/femalePatient.svg'
                          //                 : 'assets/images/malePatient.svg'
                          //             : 'assets/images/LogoIcon.svg',
                          //       )
                          //     : CachedNetworkImage(
                          //         fit: BoxFit.cover,
                          //         imageUrl: data,
                          //         progressIndicatorBuilder:
                          //             (context, url, downloadProgress) => Padding(
                          //           padding: const EdgeInsets.all(26.0),
                          //           child: CircularProgressIndicator(
                          //             value: downloadProgress.progress,
                          //             valueColor:
                          //                 const AlwaysStoppedAnimation<Color>(
                          //                     Constants.primaryColor400),
                          //             backgroundColor: Constants.primaryColor600,
                          //           ),
                          //         ),
                          //         errorWidget: (context, url, error) =>
                          //             const Icon(Icons.error),
                          //       ),
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
                    "¡Bienvenido!",
                    style: boldoHeadingTextStyle.copyWith(
                        fontSize: 24, color: Constants.primaryColor500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, dd MMMM')
                        .format(DateTime.now())
                        .capitalize(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
