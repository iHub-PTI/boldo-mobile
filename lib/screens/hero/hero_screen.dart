import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_view_indicator/page_view_indicator.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class HeroScreen extends StatelessWidget {
  final List<CarouselSlide> items = [
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/images/hero1.svg',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 0,
    ),
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/images/hero2.svg',
      boxFit: BoxFit.cover,
      alignment: Alignment.centerLeft,
      index: 1,
    ),
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/images/hero3.svg',
      boxFit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      index: 2,
    )
  ];

  final pageIndexNotifier = ValueNotifier<int>(0);
  final pageController = PageController(viewportFraction: 1.1);

  @override
  Widget build(BuildContext context) {
    dynamic _mediaQueryData = MediaQuery.of(context);
    double screenWidth = _mediaQueryData.size.width;

    double _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;

    double safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: safeBlockHorizontal * 70,
                child: AspectRatio(
                  aspectRatio: 5.0 / 6.7,
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PageView.builder(
                      itemCount: 3,
                      controller: pageController,
                      onPageChanged: (i) => pageIndexNotifier.value = i,
                      itemBuilder: (context, int currentIdx) {
                        return items[currentIdx];
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ValueListenableBuilder(
              valueListenable: pageIndexNotifier,
              builder: (context, index, child) {
                return _buildPageViewIndicator(context, index);
              },
            ),
            const Spacer(),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Constants.primaryColor500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () async {
                      _openWebView(context);
                },
                child: const Text("Iniciar Sesión")),

            const Spacer(),
          ],
        ),
      ),
    );
  }
 void _openWebView(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginWebViewHelper()),
    );
  }

  Widget _buildPageViewIndicator(BuildContext context, int indexPageView) {
    return Column(
      children: [
        PageViewIndicator(
          pageIndexNotifier: pageIndexNotifier,
          length: 3,
          normalBuilder: (animationController, index) => Circle(
            size: 10,
            color: index < indexPageView
                ? Constants.secondaryColor500
                : Constants.extraColor200,
          ),
          highlightedBuilder: (animationController, index) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animationController,
              curve: Curves.ease,
            ),
            child: Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                  color: Constants.secondaryColor200,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Align(
                alignment: Alignment.center,
                child: Circle(
                  size: 10,
                  color: Constants.secondaryColor500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 220,
          child: Text(
            indexPageView == 0
                ? "Acceso a médicos de confianza de forma instantánea"
                : indexPageView == 1
                    ? "Reserva una consulta en línea con un médico"
                    : "Fácil acceso a tus citas pasadas y futuras",
            style: boldoSubTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class CarouselSlide extends StatelessWidget {
  final String image;
  final int index;
  final BoxFit boxFit;
  final Alignment alignment;

  const CarouselSlide({
    Key key,
    @required this.image,
    @required this.boxFit,
    @required this.alignment,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(image, fit: boxFit, alignment: alignment);
  }
}
Future<void> authenticateUser(
    {@required BuildContext context, bool switchPage = true}) async {
  String keycloakRealmAddress = String.fromEnvironment('KEYCLOAK_REALM_ADDRESS',
      defaultValue: DotEnv().env['KEYCLOAK_REALM_ADDRESS']);

  FlutterAppAuth appAuth = FlutterAppAuth();

  const storage = FlutterSecureStorage();
  try {
    final AuthorizationTokenResponse result =
        await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        'boldo-patient',
        'com.penguin.boldo:/login',
        discoveryUrl: '$keycloakRealmAddress/.well-known/openid-configuration',
        scopes: ['openid', 'offline_access'],
        allowInsecureConnections: true,
      ),
    );

    await storage.write(key: "access_token", value: result.accessToken);
    await storage.write(key: "refresh_token", value: result.refreshToken);

    Provider.of<AuthProvider>(context, listen: false)
        .setAuthenticated(isAuthenticated: true);
    Response response = await dio.get("/profile/patient");
    if (response.data["photoUrl"] != null) {
      //
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("profile_url", response.data["photoUrl"]);
      await prefs.setString("gender", response.data["gender"]);
    }
  } on PlatformException catch (err, s) {
    if (!err.message.contains('User cancelled flow')) {
      print(err);
      await Sentry.captureException(err, stackTrace: s);
    }
  } catch (err, s) {
    // final snackBar = SnackBar(content: Text('Authenticaton Failed!'));
    // Scaffold.of(context).showSnackBar(snackBar);

    print(err);
    await Sentry.captureException(err, stackTrace: s);
  }
  if (switchPage)
    Provider.of<UtilsProvider>(context, listen: false)
        .setSelectedPageIndex(pageIndex: 0);
}
