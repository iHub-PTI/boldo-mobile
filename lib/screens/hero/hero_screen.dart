import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/dashboard/dashboard_screen.dart';
import 'package:boldo/screens/register_patient/credit_card_screen.dart';
import 'package:boldo/screens/register_patient/esential_data_screen.dart';
import 'package:boldo/screens/register_patient/family_members_screen.dart';
import 'package:boldo/utils/top_banner_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_view_indicator/page_view_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard/dashboard_screen.dart';
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
    ),
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/images/hero3.svg',
      boxFit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      index: 3,
    ),
  ];

  final pageIndexNotifier = ValueNotifier<int>(0);
  final pageController = PageController(viewportFraction: 1.1);

  @override
  Widget build(BuildContext context) {
    dynamic _mediaQueryData = MediaQuery.of(context);
    double screenWidth = _mediaQueryData.size.width;
    double screenheight = _mediaQueryData.size.height;

    double _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;

    double safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    double safeCardHeight = screenheight * 0.3;
    double defaultTopPadding = screenheight * 0.1;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: defaultTopPadding,
            ),
            const TopBannerPresentation(),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: safeBlockHorizontal * 70,
              height: safeCardHeight,
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
                    itemCount: 4,
                    controller: pageController,
                    onPageChanged: (i) => pageIndexNotifier.value = i,
                    itemBuilder: (context, int currentIdx) {
                      return items[currentIdx];
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ValueListenableBuilder(
              valueListenable: pageIndexNotifier,
              builder: (context, index, child) {
                return _buildPageViewIndicator(context, index);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Constants.primaryColor500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () async {
                    // final SharedPreferences prefs =
                    //     await SharedPreferences.getInstance();
                    // prefs.setBool("onboardingCompleted", true);

                    Provider.of<UtilsProvider>(context, listen: false)
                        .setSelectedPageIndex(pageIndex: 2);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: "/home"),
                        builder: (context) => DashboardScreen(),
                      ),
                    );
                  },
                  child: const Text("Iniciar Sesión"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Constants.extraColor100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () async {
                    // final SharedPreferences prefs =
                    //     await SharedPreferences.getInstance();
                    // prefs.setBool("onboardingCompleted", true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: "/register"),
                        builder: (context) => EsentialDataScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
            // const Spacer(),
            // const Text(
            //   "¿Quieres dar un vistazo?",
            //   style: boldoSubTextStyle,
            //   textAlign: TextAlign.center,
            // ),
            // TextButton(
            //   onPressed: () async {
            //     // final SharedPreferences prefs =
            //     //     await SharedPreferences.getInstance();
            //     // prefs.setBool("onboardingCompleted", true);

            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         settings: const RouteSettings(name: "/home"),
            //         builder: (context) => DashboardScreen(),
            //       ),
            //     );
            //   },
            //   child: Text(
            //     'Explora Boldo',
            //     style: boldoSubTextStyle.copyWith(
            //         color: Constants.secondaryColor500),
            //   ),
            // ),
            // const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageViewIndicator(BuildContext context, int indexPageView) {
    return Column(
      children: [
        PageViewIndicator(
          pageIndexNotifier: pageIndexNotifier,
          length: 4,
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
        descriptionHero(indexPageView),
      ],
    );
  }

  SizedBox descriptionHero(int indexPageView) {
    String title = "";
    switch (indexPageView) {
      case 0:
        title = "¡Consultas médicas desde la comodidad de tu hogar!";
        break;
      case 1:
        title = "¡Tu historial clínico centralizado en tus manos!";

        break;
      case 2:
        title =
            "¡Todas tus recetas médicas y las de tu familia en un solo lugar!";
        break;
      case 3:
        title =
            "¡Durante las consultas médicas podrás proveer al médico con información en tiempo real!";
        break;
      default:
    }
    return SizedBox(
      width: 300,
      height: 70,
      child: Text(
        title,
        style: boldoSubTextStyle,
        textAlign: TextAlign.center,
      ),
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
