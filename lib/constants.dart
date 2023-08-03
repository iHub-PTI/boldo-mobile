import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color otherColor400 = Color(0xffEB8B76);
  static const Color otherColor800 = Color(0xffdaebed);

  //Accordion background color
  static const Color accordionbg = Color(0xfff3FAF7);
  static const Color dividerAccordion = Color(0x40F08F77);

  // SOEP final string
  static const String objective = "Objetivo";
  static const String subjective = "Subjetivo";
  static const String evaluation = "Evaluación";
  static const String plan = "Plan";
}

const String genericError = "Algo salió mal, vuelve a intentarlo más tarde";
const String chooseAll = "Seleccionar todos";

// Text Style
const boldoHeadingTextStyle = TextStyle(
  color: ConstantsV2.inactiveText,
  fontStyle: FontStyle.normal,
  fontSize: 18,
  fontWeight: FontWeight.w400,
  fontFamily: 'Montserrat',
);

const boldoTitleRegularTextStyle = TextStyle(
  color: ConstantsV2.lightest,
  fontStyle: FontStyle.normal,
  fontSize: 24,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const bodyMediumRegular = TextStyle(
  color: ConstantsV2.lightest,
  fontStyle: FontStyle.normal,
  fontSize: 12,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoTitleBlackTextStyle = TextStyle(
  color: ConstantsV2.activeText,
  fontStyle: FontStyle.normal,
  fontSize: 24,
  fontWeight: FontWeight.w500,
  fontFamily: 'Montserrat',
);

const boldoScreenTitleTextStyle = TextStyle(
  color: ConstantsV2.activeText,
  fontStyle: FontStyle.normal,
  fontSize: 24,
  fontWeight: FontWeight.w400,
  fontFamily: 'Montserrat',
);

const boldoScreenSubtitleTextStyle = TextStyle(
  color: ConstantsV2.activeText,
  fontStyle: FontStyle.normal,
  fontSize: 18,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoSubTextStyle = TextStyle(
  color: ConstantsV2.inactiveText,
  fontStyle: FontStyle.normal,
  fontSize: 18,
  fontWeight: FontWeight.w400,
  fontFamily: 'Montserrat',
);

const boldoSubTextMediumStyle = TextStyle(
  color: ConstantsV2.activeText,
  fontStyle: FontStyle.normal,
  fontSize: 16,
  fontWeight: FontWeight.w400,
  fontFamily: 'Montserrat',
);

TextStyle bodyLarge = GoogleFonts.montserrat().copyWith(
  fontWeight: FontWeight.w300,
  fontSize: 14,
);

TextStyle bodyP = GoogleFonts.montserrat().copyWith(
  fontWeight: FontWeight.w300,
  fontSize: 10,
);

TextStyle bodyLargeBlack = GoogleFonts.montserrat().copyWith(
  fontWeight: FontWeight.w500,
  fontSize: 14,
);

TextStyle bodySmallRegular = GoogleFonts.montserrat().copyWith(
  fontWeight: FontWeight.w300,
  fontSize: 10,
);

TextStyle labelMedium = GoogleFonts.workSans().copyWith(
  fontWeight: FontWeight.w500,
  fontSize: 14,
  fontStyle: FontStyle.normal,
);

const boldoInfoTextStyle = TextStyle(
  color: ConstantsV2.activeText,
  fontFamily: 'Montserrat',
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w300,
  fontSize: 14
);

const boldoCardHeadingTextStyle = TextStyle(
  color: Colors.white,
  fontStyle: FontStyle.normal,
  fontSize: 17,
  fontWeight: FontWeight.w600,
  fontFamily: 'Montserrat',
);

const boldoCardSubtitleTextStyle = TextStyle(
  color: Colors.white,
  fontStyle: FontStyle.normal,
  fontSize: 16,
  fontWeight: FontWeight.w400,
  fontFamily: 'Montserrat',
);

const boldoCorpMediumTextStyle = TextStyle(
  color: ConstantsV2.lightGrey,
  fontStyle: FontStyle.normal,
  fontSize: 14,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoCorpMediumWithLineSeparationLargeTextStyle = TextStyle(
  color: ConstantsV2.lightGrey,
  fontStyle: FontStyle.normal,
  fontSize: 14,
  height: 1.7,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoBodyLRegularTextStyle = TextStyle(
  color: ConstantsV2.lightGrey,
  fontStyle: FontStyle.normal,
  fontSize: 14,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoBodySRegularTextStyle = TextStyle(
  color: ConstantsV2.lightGrey,
  fontStyle: FontStyle.normal,
  fontSize: 10,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoBodySBlackTextStyle = TextStyle(
  color: ConstantsV2.lightGrey,
  fontStyle: FontStyle.normal,
  fontSize: 10,
  fontWeight: FontWeight.w500,
  fontFamily: 'Montserrat',
);

const boldoCorpMediumBlackTextStyle = TextStyle(
  color: ConstantsV2.lightGrey,
  fontStyle: FontStyle.normal,
  fontSize: 14,
  fontWeight: FontWeight.w500,
  fontFamily: 'Montserrat',
);

const boldoCorpSmallTextStyle = TextStyle(
  color: ConstantsV2.lightGrey,
  fontStyle: FontStyle.normal,
  fontSize: 10,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoCorpSmallSTextStyle = TextStyle(
  color: ConstantsV2.lightGrey,
  fontStyle: FontStyle.normal,
  fontSize: 12,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoCorpSmallInterTextStyle = TextStyle(
  color: ConstantsV2.lightGrey,
  fontStyle: FontStyle.normal,
  fontSize: 12,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoBillboardTextStyleAlt = TextStyle(
  color: ConstantsV2.inactiveText,
  fontStyle: FontStyle.normal,
  fontSize: 40,
  fontFamily: 'Montserrat',
);

const boldoTabHeaderTextStyle = TextStyle(
  fontStyle: FontStyle.normal,
  fontSize: 19,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const boldoTabHeaderSelectedTextStyle = TextStyle(
  fontStyle: FontStyle.normal,
  fontSize: 19,
  fontWeight: FontWeight.w500,
  fontFamily: 'Montserrat',
);

const boldoTabHeaderUnselectedTextStyle = TextStyle(
  fontStyle: FontStyle.normal,
  fontSize: 19,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

const BigButton = TextStyle(
  color: ConstantsV2.lightest,
  fontStyle: FontStyle.normal,
  fontSize: 15,
  fontWeight: FontWeight.w300,
  fontFamily: 'Montserrat',
);

BoxShadow shadowRegular = const BoxShadow(
  color: Color(0x0C000000),
  blurRadius: 4,
  offset: Offset(0, 2),
  spreadRadius: 0,
);

BoxShadow shadowHeader = const BoxShadow(
  color: Color(0x07000000),
  blurRadius: 10,
  offset: Offset(0, 4),
  spreadRadius: 0,
);

BoxShadow shadowAttachStudy = const BoxShadow(
  color: Color(0x0C000000),
  blurRadius: 4,
  offset: Offset(0, 2),
  spreadRadius: 0,
);

const BoxDecoration buttonFXSecondaryStyle = BoxDecoration(
  boxShadow: [
    BoxShadow(
      offset: Offset(0, 2),
      color: Color(0xffFEAD88),
      spreadRadius: -4,
      blurRadius: 4,
    ),
    BoxShadow(
      offset: Offset(0, 2),
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 4,
    ),
    BoxShadow(
      offset: Offset(0, 0),
      color: Color.fromRGBO(253, 165, 125, 0.5),
      blurRadius: 4,
    )
  ]
);

ThemeData boldoTheme = ThemeData(
  fontFamily: 'Montserrat',
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: MaterialStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w500, fontSize: 16,
            color: ConstantsV2.BGNeutral
        ),
      ),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return ConstantsV2.gray; // Disabled color
        }
        return ConstantsV2.orange; // Regular color
      }),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ConstantsV2.secondaryRegular,
      textStyle: boldoSubTextMediumStyle.copyWith(color: ConstantsV2.secondaryRegular),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    ),
  ),
  toggleableActiveColor: ConstantsV2.orange,
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: ConstantsV2.orange, width: 5),
      borderRadius: BorderRadius.circular(4),
    ),
  ),
  unselectedWidgetColor: ConstantsV2.orange,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    extendedTextStyle:
        const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
    extendedPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    backgroundColor: ConstantsV2.orange,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: ConstantsV2.orange),
      foregroundColor: ConstantsV2.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
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
    errorStyle: bodySmallRegular.copyWith(
      color: ConstantsV2.systemFail
    )
  ),
  primaryColor: Colors.white,
  scaffoldBackgroundColor: ConstantsV2.BGNeutral,
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

// Colors Boldo V2
class ConstantsV2 {
  // background colors palette
  static const Color primaryColor100 = Color(0xffFFFFFF);
  static const Color primaryColor200 = Color(0xff74B49E);
  static const Color primaryColor300 = Color(0xffFDA57D);

  static const Color menuBackgroundColor100 = Color(0xff364F6B);
  static const Color menuBackgroundColor200 = Color(0xff74B49E);
  static const Color menuBackgroundColor300 = Color(0xffFFF7A3E);

  // stops primary background colors
  static const double primaryStop100 = -0.14;
  static const double primaryStop200 = 1.25;
  static const double primaryStop300 = 1.79;

  static const double menuBackgroundStop100 = 0.0;
  static const double menuBackgroundStop200 = 0.30;
  static const double menuBackgroundStop300 = 1.0;

  // button color
  static const Color buttonPrimaryColor100 = Color(0xffEB8B76);
  static const Color rightBottonNavigaton = Color.fromRGBO(255, 139, 118, 0.1);

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
  static const Color inactiveText = Color(0xff707882);
  static const Color activeText = Color(0xff424649);

  // Input line border
  static const Color enableBorded = Color(0xff424649);
  static const Color focuseBorder = Color(0xff707882);

  static const Color patientAppBarColor100 = Color(0xff364F6B);
  static const Color patientAppBarColor200 = Color(0xff74B49E);
  static const Color patientAppBarColor300 = Color(0xffFDA57D);
  static const Color familyAppBarColor100 = Color(0xff364F6B);
  static const Color familyAppBarColor200 = Color(0xff74B49E);
  static const Color familyAppBarColor300 = Color(0xff5E7B97);

  // stops primary background colors
  static const double patientAppBarStop100 = 0;
  static const double patientAppBarStop200 = 0.3067;
  static const double patientAppBarStop300 = 1.0;
  static const double familyAppBarStop100 = 0;
  static const double familyAppBarStop200 = 0.3762;
  static const double familyAppBarStop300 = 1.0;

  // Sing In background colors
  static const Color singInPrimaryColor100 = Color(0xff364F6B);
  static const Color singInPrimaryColor200 = Color(0xff74B49E);
  static const Color singInPrimaryColor300 = Color(0xff93D2C2);
  static const Color singInSecondaryColor100 = Color(0xffFDA57D);
  static const Color singInSecondaryColor200 = Color(0xff62B7DC);
  static const Color singInSecondaryColor300 = Color(0xff639890);

  // Sing In background stops
  static const double singInPrimaryStop100 = 0;
  static const double singInPrimaryStop200 = 0.6757;
  static const double singInPrimaryStop300 = 1.0;
  static const double singInSecondaryStop100 = 0;
  static const double singInSecondaryStop200 = 0.5479;
  static const double singInSecondaryStop300 = 1.0;

  // Family Connect background colors
  static const Color familyConnectPrimaryColor100 = Color(0xff364F6B);
  static const Color familyConnectPrimaryColor200 = Color(0xff74B49E);
  static const Color familyConnectPrimaryColor300 = Color(0xffFDA57D);
  static const Color familyConnectSecondaryColor100 = Color(0xff364F6B);
  static const Color familyConnectSecondaryColor200 = Color(0xff74B49E);
  static const Color familyConnectSecondaryColor300 = Color(0xff93D2C2);

  // Family Connect background stops
  static const double familyConnectPrimaryStop100 = 0;
  static const double familyConnectPrimaryStop200 = 0.6757;
  static const double familyConnectPrimaryStop300 = 1.0;
  static const double familyConnectSecondaryStop100 = 0;
  static const double familyConnectSecondaryStop200 = 0.5479;
  static const double familyConnectSecondaryStop300 = 1.0;

  // colors
  static const Color lightGrey = Color(0xffF8F8F8);
  static const Color lightest = Color(0xffFFFFFF);
  static const Color green = Color(0xff28B3BB);
  static const Color lightGreen = Color.fromRGBO(40, 179, 187, 0.13);
  static const Color veryLightBlue = Color(0xffB1C3D7);
  static const Color yellow = Color(0xffF9D620);
  static const Color darkBlue = Color(0xff364F6B);
  static const Color blueDark = Color(0xff364F6B);
  static const Color blueLight = Color(0xffB1C3D7);
  static const Color orange = Color(0xffEB8B76);
  static const Color lightAndClear = Color(0xffF5F5F5);
  static const Color gray = Color(0xffCFCFCF);
  static const Color grayLight = Color(0xffF8F8F8);
  static const Color grayLightest = Color(0xffFBFBFB);
  static const Color grayDark = Color(0xff52565A);
  static Color grayLightAndClear = const Color(0xffF5F5F5).withOpacity(.8);
  static const Color BGNeutral = Color(0xffF5F5F5);
  static const Color CardBG = Color(0xffEAEAEA);
  static const Color primaryRegular = Color(0xff28B3BB);
  static Color primaryLightAndClear = const Color(0xff28B3BB).withOpacity(.13);

  static const Color secondaryRegular = Color(0xffEB8B76);
  static Color secondaryLightAndClear = const Color(0xffEB8B76).withOpacity(0.1);

  static const Color systemSuccess = Color(0xff4AB648);
  static const Color systemFail = Color(0xffC53030);
  static const Color accentRegular = Color(0xffF9D620);

  // home heights
  static double homeAppBarMaxHeight = 132.0;
  static double homeAppBarMinHeight = 76.0;
  static double homeCarouselContainerMaxHeight = 162.0;
  static double homeCarouselContainerMinHeight = 82.0;
  static double homeCarouselTitleContainerMaxHeight = 32.0;
  static double homeCarouselTitleContainerMinHeight = 0.0;
  static double homeCarouselCardMaxHeight = 130.0;
  static double homeCarouselCardMinHeight = 50.0;
  static double homeCarouselCardMaxWidth = 110.0;
  static double homeCarouselCardMinWidth = 50.0;
  static double homeCarouselCardMaxRadius = 100.0;
  static double homeCarouselCardMinRadius = 10.0;
  static double homeFeedTitleContainerMaxHeight = 32.0;
  static double homeFeedTitleContainerMinHeight = 32.0;
  static double homeCarouselPadding = 24.0;

  static double homeExpandedMaxHeight = homeAppBarMaxHeight + homeCarouselContainerMaxHeight + homeCarouselTitleContainerMaxHeight + homeFeedTitleContainerMaxHeight + homeCarouselPadding + homeCarouselPadding;
  static double homeExpandedMinHeight = homeAppBarMinHeight + homeCarouselContainerMinHeight + homeCarouselTitleContainerMinHeight + homeFeedTitleContainerMinHeight + homeCarouselPadding + homeCarouselPadding;

}

// Constants

const String isFamily = 'isFamily';
const int minutesToCloseAppointment = 120;
const String uploadedStudySuccessfullyMessage = "¡Estudio subido!";
const String dependentSuccessAdded = '¡Dependiente agregado!';
DateTime minDate = DateTime(1900, 1, 1);
DateTime minDateDigit = DateTime(1000, 1, 1);
enum StatusRequestOrganization  {Approved, Pending, Rejected}
const int timeToShowAppointmentsOnHoldInMonth = 1;
const int timeToShowStudyOrderInMonth = 1;
const Duration appearWidgetDuration = Duration(seconds: 1);
