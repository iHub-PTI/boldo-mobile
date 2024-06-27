import 'package:boldo/constants.dart';
import 'package:boldo/screens/pre_register_notify/pre_register_screen.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeroScreen extends StatelessWidget {
  HeroScreen({super.key});

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
  ];

  final pageIndexNotifier = ValueNotifier<int>(0);
  final pageController = PageController(viewportFraction: 1.1);

  @override
  Widget build(BuildContext context) {
    final dynamic mediaQueryData = MediaQuery.of(context);
    final double screenWidth = mediaQueryData.size.width;

    final double safeAreaHorizontal =
        mediaQueryData.padding.left + mediaQueryData.padding.right;

    final safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Align(
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
                backgroundColor: Constants.primaryColor500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final onboardingCompleted =
                    prefs.getBool('preRegisterNotify') ?? false;
                if (onboardingCompleted == true) {
                  _openWebView(context);
                } else {
                  //show pre register
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreRegisterScreen(),
                    ),
                  );
                }
              },
              child: const Text('Iniciar Sesión'),
            ),
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
                ? 'Acceso a médicos de confianza de forma instantánea'
                : indexPageView == 1
                    ? 'Reserva una consulta en línea con un médico'
                    : 'Fácil acceso a tus citas pasadas y futuras',
            style: boldoSubTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class CarouselSlide extends StatelessWidget {
  const CarouselSlide({
    required this.image,
    required this.boxFit,
    required this.alignment,
    required this.index,
    super.key,
  });
  final String image;
  final int index;
  final BoxFit boxFit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(image, fit: boxFit, alignment: alignment);
  }
}
