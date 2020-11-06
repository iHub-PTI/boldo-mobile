import 'package:boldo/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_view_indicator/page_view_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard/dashboard_screen.dart';
import '../../constants.dart';

class HeroScreen extends StatelessWidget {
  final List<CarouselSlide> items = [
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/hero/hero1.png',
      index: 0,
    ),
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/hero/hero2.png',
      index: 1,
    ),
    CarouselSlide(
      key: UniqueKey(),
      image: 'assets/hero/hero3.png',
      index: 2,
    )
  ];

  final pageIndexNotifier = ValueNotifier<int>(0);
  final pageController = PageController(viewportFraction: 1.1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 45,
                ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 360,
                    width: 270,
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
                          return FractionallySizedBox(
                              widthFactor: 1 / pageController.viewportFraction,
                              child: items[currentIdx]);
                        },
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
                // const SizedBox(
                //   height: 48,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //           primary: Constants.primaryColor500,
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(6),
                //           ),
                //         ),
                //         onPressed: () async {
                //           final SharedPreferences prefs =
                //               await SharedPreferences.getInstance();
                //           prefs.setBool("onboardingCompleted", true);
                //         },
                //         child: const Text("Iniciar Sesión")),
                //     const SizedBox(
                //       width: 30,
                //     ),
                //     OutlineButton(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(6),
                //       ),
                //       onPressed: () async {
                //         final SharedPreferences prefs =
                //             await SharedPreferences.getInstance();
                //         prefs.setBool("onboardingCompleted", true);
                //       },
                //       child: const Text("Registrarse"),
                //     )
                //   ],
                // ),
                const SizedBox(
                  height: 48,
                ),
                const Text(
                  "¿Quieres dar un vistazo?",
                  style: boldoSubTextStyle,
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("onboardingCompleted", true);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Explora Boldo',
                    style: boldoSubTextStyle.copyWith(
                        color: Constants.secondaryColor500),
                  ),
                ),
              ],
            ),
          )),
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

  const CarouselSlide({
    Key key,
    @required this.image,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          image,
          width: double.infinity,
        ),
      ),
    );
  }
}
