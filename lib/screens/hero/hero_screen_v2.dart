import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/pre_register_notify/pre_register_screen.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class HeroScreenV2 extends StatelessWidget {
  final List<CarouselSlide> items = [
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/images/hero1.png',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 0,
    ),
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/images/hero2.png',
      boxFit: BoxFit.cover,
      alignment: Alignment.centerLeft,
      index: 1,
    ),
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/images/hero3.png',
      boxFit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      index: 2,
    )
  ];

  @override
  Widget build(BuildContext context) {
    dynamic _mediaQueryData = MediaQuery.of(context);
    double screenWidth = _mediaQueryData.size.width;

    double _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;

    double safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration( // Background linear gradient
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color> [
              ConstantsV2.primaryColor100,
              ConstantsV2.primaryColor200,
              ConstantsV2.primaryColor300
            ],
            stops: <double> [
              ConstantsV2.primaryStop100,
              ConstantsV2.primaryStop200,
              ConstantsV2.primaryStop300,
            ]
          )
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: ListView.builder(
                    itemCount: items.length*2+1,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, int index) {
                      return _buildCarousel(context, index);
                    },
                  ),
                ),
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
                    final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    bool onboardingCompleted =
                        prefs.getBool("preRegisterNotify") ?? false;
                    if (onboardingCompleted == true) {
                      _openWebView(context);
                    } else {
                      //show pre register
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PreRegisterScreen()),
                      );
                    }
                  },
                  child: const Text("Iniciar Sesión")),
              const Spacer(),
            ],
          ),
        ),
      )

    );
  }
  final pageIndexNotifier = ValueNotifier<int>(0);

  final pageController = PageController(viewportFraction: 1.1);

  void _openWebView(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginWebViewHelper()),
    );
  }

  Widget _buildCarousel(BuildContext context, int carouselIndex){
    if ( carouselIndex % 2 == 0 ) // Padding between Cards
      return const Padding(padding: EdgeInsets.only(left: 16.0));
    return InkWell(
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 6,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        ),
        child: CustomCardAnimated(carouselSlide: items[(carouselIndex-1)~/2])

      ),
    );
  }

  Widget _buildPageViewIndicator(BuildContext context, int indexPageView) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        PageViewDotIndicator(
          currentItem: pageIndexNotifier.value,
          count: 3,
          unselectedColor: Constants.extraColor200,
          selectedColor: Constants.secondaryColor500,
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
    Key? key,
    required this.image,
    required this.boxFit,
    required this.alignment,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(image, fit: boxFit, alignment: alignment);
  }
}


class CustomCardAnimated extends StatefulWidget {

  final CarouselSlide? carouselSlide;

  const CustomCardAnimated({
    Key? key,
    required this.carouselSlide,
  }) : super(key: key);

  @override
  State<CustomCardAnimated> createState() => _CustomCardAnimatedState(carouselSlide: carouselSlide);
}

class _CustomCardAnimatedState extends State<CustomCardAnimated>{
  // first state
  Color? color100;
  Color? color200;
  double? stopColor100;
  double? stopColor200;

  // animation
  bool? animate;
  bool? textAppear;

  // text and image
  CarouselSlide? carouselSlide;

  _CustomCardAnimatedState({
    required this.carouselSlide
  });

  @override
  void initState() {
    animate = false;
    textAppear = false;
    showInfoPlayer(animate!);
    super.initState();
  }

  void showInfoPlayer(bool animate) {
    setState(() {
      if (animate) {
        color100 = ConstantsV2.secondaryCardHeroColor100.withOpacity(0.97);
        color200 = ConstantsV2.secondaryCardHeroColor100.withOpacity(0);
        stopColor100 = ConstantsV2.secondaryCardStop100;
        stopColor200 = ConstantsV2.secondaryCardStop200;
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            textAppear = true;
          });
        });
      } else {
        color100 = ConstantsV2.primaryCardHeroColor100.withOpacity(0.97);
        color200 = ConstantsV2.primaryCardHeroColor100.withOpacity(0);
        stopColor100 = ConstantsV2.primaryCardStop100;
        stopColor200 = ConstantsV2.primaryCardStop200;
        textAppear = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if(!(animate!))
            setState(() {
              animate = true;
              showInfoPlayer(animate!);
              print(carouselSlide!.image);
            });
          else
            setState(() {
              animate = false;
              showInfoPlayer(animate!);
            });
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 216, maxHeight: 319),
          alignment: Alignment.bottomLeft,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(carouselSlide!.image)
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration( // Back ground linear gradient
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: <Color> [
                      color100!,
                      color200!,
                    ],
                    stops: <double> [
                      stopColor100!,
                      stopColor200!,
                    ]
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedOpacity(
                  opacity: textAppear! ? 0 : 1,
                  duration: Duration(milliseconds: textAppear! ? 200 : 200),
                  child: const
                    Text(
                      "Consultas Remotas",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                ),
              ),
              Align(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    opacity: textAppear! ? 1 : 0,
                    duration: Duration(milliseconds: textAppear! ? 400 : 100),
                    curve: Curves.easeOut,
                    child: Column(
                      children: [
                        const Expanded(
                          child: Text(
                            "Consultas remotas",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Text(
                            "Con Boldo podés agendar, gestionar y asistir a consultas remotas. Todo desde donde estés",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            "Ver doctores disponibles",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        /*Container(
                          padding: const EdgeInsets.only(top: 10.0),
                          width: 270,
                          child: const Text(
                            "Mohamed Salah is one of the most prolific forwards in European football and a Champions League and Premier League winner with Liverpool.",
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> authenticateUser(
    {required BuildContext context, bool switchPage = true}) async {
  String keycloakRealmAddress = String.fromEnvironment('KEYCLOAK_REALM_ADDRESS',
      defaultValue: dotenv.env['KEYCLOAK_REALM_ADDRESS']!);

  FlutterAppAuth appAuth = FlutterAppAuth();

  const storage = FlutterSecureStorage();
  try {
    final AuthorizationTokenResponse? result =
    await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        'boldo-patient',
        'com.penguin.boldo:/login',
        discoveryUrl: '$keycloakRealmAddress/.well-known/openid-configuration',
        scopes: ['openid', 'offline_access'],
        allowInsecureConnections: true,
      ),
    );

    await storage.write(key: "access_token", value: result!.accessToken);
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
    if (!err.message!.contains('User cancelled flow')) {
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
