import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/pre_register_notify/pre_register_screen.dart';
import 'package:boldo/screens/register/sign_up_basic_info.dart';
import 'package:boldo/screens/register/sign_up_phone_number.dart';
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
      title: 'Consultas remotas',
      description: 'Con Boldo podés agendar, gestionar y asistir a consultas'
          'remotas. Todo desde donde estés.',
      secondaryText: 'ver doctores disponibles',
    ),
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/images/hero2.png',
      boxFit: BoxFit.cover,
      alignment: Alignment.centerLeft,
      index: 1,
      title: 'Recetas electrónicas',
      description: '',
      secondaryText: '',
    ),
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/images/hero3.png',
      boxFit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      index: 2,
      title: 'Estudios',
      description: '',
      secondaryText: '',
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration( // Background linear gradient
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color> [
                  ConstantsV2.primaryColor100,
                  ConstantsV2.primaryColor200,
                  ConstantsV2.primaryColor300,
                ],
                stops: <double> [
                  ConstantsV2.primaryStop100,
                  ConstantsV2.primaryStop200,
                  ConstantsV2.primaryStop300,
                ]
              )
            ),
          ),
          Opacity(
            opacity: 0.2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/hero_background.png')
                ),
              ),
            ),
          ),
          Container(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container (
                    margin: const EdgeInsets.all(16.0),
                    child: Align(
                        child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/icon/logo_text.svg'),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  "Tu ecosistema integral de servicios integrales de salud",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Montserrat',
                                    color: Color(0xffF5F5F5),
                                  ),
                                ),
                              )
                            ]
                        )
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: ListView.builder(
                        itemCount: items.length*2+1,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: _buildCarousel,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    margin: const EdgeInsets.only(right: 16, bottom: 16),
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: ConstantsV2.buttonPrimaryColor100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () async {
                        final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        bool onboardingCompleted =
                            prefs.getBool("preRegisterNotify") ?? false;
                        if (onboardingCompleted == true) {
                          _openRegister(context);
                        } else {
                          //show pre register
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPhoneInfo()),
                          );
                        }
                      },
                      child: Container(
                          constraints: const BoxConstraints(maxWidth: 142, maxHeight: 48),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "comenzar",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Montserrat',
                                    color: ConstantsV2.primaryColor,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.only(left: 10.0)),
                                SvgPicture.asset(
                                  'assets/icon/arrow-right.svg',
                                  semanticsLabel: 'Start icon',
                                ),
                              ]
                          )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]
      )

    );
  }
  final pageIndexNotifier = ValueNotifier<int>(0);

  final pageController = PageController(viewportFraction: 1.1);

  void _openRegister(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPhoneInfo()),
    );
  }

  Widget _buildCarousel(BuildContext context, int carouselIndex){
    if ( carouselIndex % 2 == 0 ) // Padding between Cards
      return const Padding(padding: EdgeInsets.only(left: 16.0));
    return InkWell(
      child: CustomCardAnimated(carouselSlide: items[(carouselIndex-1)~/2])
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
  final String title;
  final String description;
  final String secondaryText;

  const CarouselSlide({
    Key? key,
    required this.image,
    required this.boxFit,
    required this.alignment,
    required this.index,
    required this.title,
    required this.description,
    required this.secondaryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(image, fit: boxFit, alignment: alignment);
  }
}

/// return Card class with image background and linear gradient colors, required
/// a [CarouselSlide] with image and text to use the image as background an text
/// as description.
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
  // colors and stops that define a visual state of the card
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

        // To delay a state change for animated false to animated true
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            textAppear = true;
          });
        });
      } else {
        color100 = ConstantsV2.primaryCardHeroColor100.withOpacity(0.81);
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
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          if(!(animate!))
            setState(() {
              animate = true;
              showInfoPlayer(animate!);
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
              // Container that define the image background
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(carouselSlide!.image)
                  ),
                ),
              ),

              // Container that define the linear gradient background
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

              // Container used for group text info
              Container(
                margin: const EdgeInsets.only(left:16, right: 16, top: 16, bottom: 16),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedOpacity(
                        opacity: textAppear! ? 0 : 1,
                        duration: Duration(milliseconds: textAppear! ? 200 : 200),
                        child:
                        Text(
                          carouselSlide!.title,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Montserrat',
                            color: Color(0xffF5F5F5),
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
                              Expanded(
                                child: Text(
                                  carouselSlide!.title,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Montserrat',
                                    color: Color(0xffF5F5F5),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  carouselSlide!.description,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Montserrat',
                                    color: Color(0xffF5F5F5),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    primary: Constants.primaryColor500.withOpacity(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () async {

                                  },
                                  child: Text(
                                    carouselSlide!.secondaryText,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Montserrat',
                                      color: Color(0xffF5F5F5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                )
              ),

            ],
          ),
        ),
      ),
    );
  }
}
