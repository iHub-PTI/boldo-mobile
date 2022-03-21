import 'package:flutter/material.dart';

class Constants {
  // primary color palette
  static const Color primaryColor100 = Color(0xffD4F2F3);
  static const Color primaryColor200 = Color(0xffA9E5E7);
  static const Color primaryColor300 = Color(0xff7DD8DA);
  static const Color primaryColor400 = Color(0xff65CFD3);
  static const Color primaryColor500 = Color(0xff27BEC2);
  static const Color primaryColor600 = Color(0xff13A5A9);
  static const Color primaryColor700 = Color(0xff177274);
  static const Color primaryColor800 = Color(0xff104C4E);
  static const Color primaryColor900 = Color(0xff082627);

  // secondary secondary palette
  static const Color secondaryColor100 = Color(0xffFCE9E4);
  static const Color secondaryColor200 = Color(0xffF9D2C9);
  static const Color secondaryColor300 = Color(0xffFCBEAF);
  static const Color secondaryColor400 = Color(0xffF3A592);
  static const Color secondaryColor500 = Color(0xffF08F77);
  static const Color secondaryColor600 = Color(0xffC0725F);
  static const Color secondaryColor700 = Color(0xff905647);
  static const Color secondaryColor800 = Color(0xff603930);
  static const Color secondaryColor900 = Color(0xff301D18);

  // tertiary color palette
  static const Color tertiaryColor100 = Color(0xffFFFDFB);
  static const Color tertiaryColor200 = Color(0xffFFFBF6);
  static const Color tertiaryColor300 = Color(0xffFFF8F2);
  static const Color tertiaryColor400 = Color(0xffFFF6ED);
  static const Color tertiaryColor500 = Color(0xffFFF4E9);
  static const Color tertiaryColor600 = Color(0xffCCC3BA);
  static const Color tertiaryColor700 = Color(0xff99928C);
  static const Color tertiaryColor800 = Color(0xff66625D);
  static const Color tertiaryColor900 = Color(0xff33312F);

  // gray palette
  static const Color grayColor50 = Color(0xffFBFDFE);
  static const Color grayColor200 = Color(0xffEDF2F7);
  static const Color grayColor500 = Color(0xffA0AEC0);
  static const Color grayColor700 = Color(0xff364152);
  static const Color grayColor800 = Color(0xff27303F);

  // extra color palette
  static const Color extraColor100 = Color(0xffFFFFFF);
  static const Color extraColor200 = Color(0xffE5E7EB);
  static const Color extraColor300 = Color(0xff6B7280);
  static const Color extraColor400 = Color(0xff364152);

  // others color palette
  static const Color otherColor100 = Color(0xffDF6D51);
  static const Color otherColor200 = Color(0xffEE983F);
  static const Color otherColor300 = Color(0xffC53030);

  //Accordion background color
  static const Color accordionbg = Color(0xfff3FAF7);
  static const Color dividerAccordion = Color(0x40F08F77);

 
  // SOEP final string
  static const String objective = "Objetivo";
  static const String subjective = "Subjetivo";
  static const String evaluation = "Evaluación";
  static const String plan = "Plan";
  
}

// Text Style
const boldoHeadingTextStyle = TextStyle(
  color: Constants.extraColor400,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

const boldoSubTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Constants.extraColor300);

ThemeData boldoTheme = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontWeight: FontWeight.w500),
      primary: Constants.primaryColor500,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
        color: ConstantsV2.enableBorded,
        width: 1.0,
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
        color: ConstantsV2.focuseBorder,
        width: 1.25,
      ),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
        color: ConstantsV2.buttonPrimaryColor100,
      ),
    ),
    errorBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
        color: ConstantsV2.buttonPrimaryColor100,
        width: 1.0,
      ),
    ),
  ),
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);


// Colors Boldo V2
class ConstantsV2 {
  // background primary color palette
  static const Color primaryColor100 = Color(0xffFFFFFF);
  static const Color primaryColor200 = Color(0xff74B49E);
  static const Color primaryColor300 = Color(0xffFDA57D);

  // stops primary background colors
  static const double primaryStop100 = -0.14;
  static const double primaryStop200 = 1.25;
  static const double primaryStop300 = 1.79;

  // button color
  static const Color buttonPrimaryColor100 = Color(0xffEB8B76);

  // hero cards colors gradient
  static const Color primaryCardHeroColor100 = Color(0xffFDA57D);

  // stops hero cards background colors
  static const double primaryCardStop100 = 0.20;
  static const double primaryCardStop200 = 0.72;

  // hero cards colors gradient
  static const Color secondaryCardHeroColor100 = Color(0xffFDA57D);

  // stops hero cards background colors
  static const double secondaryCardStop100 = 0.82;
  static const double secondaryCardStop200 = 1.46;

  // Text color
  static const Color primaryColor = Color(0xffF5F5F5);

  // Input line border
  static const Color enableBorded = Color(0xff424649);
  static const Color focuseBorder = Color(0xff707882);

}