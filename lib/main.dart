import 'package:boldo/provider/user_provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import './network/connection_status.dart';
import './network/http.dart';
import './provider/auth_provider.dart';
import './screens/dashboard/dashboard_screen.dart';
import './screens/Hero/hero_screen.dart';

import './constants.dart';
import './size_config.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();
  Intl.defaultLocale = "es";
  await DotEnv().load('.env');
  GestureBinding.instance.resamplingEnabled = true;
  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool("onboardingCompleted") ?? false;
  initDio(navKey: navKey);
  const storage = FlutterSecureStorage();
  String value = await storage.read(key: "access_token");

  runApp(MyApp(
    onboardingCompleted: onboardingCompleted,
    session: value,
  ));
}

class MyApp extends StatefulWidget {
  final bool onboardingCompleted;
  final String session;
  const MyApp(
      {Key key, @required this.onboardingCompleted, @required this.session})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<UtilsProvider>(create: (_) => UtilsProvider()),
        ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(widget.session != null ? true : false)),
      ],
      child: FullApp(onboardingCompleted: widget.onboardingCompleted),
    );
  }
}

class FullApp extends StatelessWidget {
  const FullApp({
    Key key,
    @required this.onboardingCompleted,
  }) : super(key: key);

  final bool onboardingCompleted;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      title: 'Boldo',
      theme: boldoTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          boldoTheme.textTheme,
        ),
      ),
      home: LandingScreen(onboardingCompleted: onboardingCompleted),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key key, @required this.onboardingCompleted})
      : super(key: key);
  final bool onboardingCompleted;

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return widget.onboardingCompleted ? DashboardScreen() : HeroScreen();
  }
}
