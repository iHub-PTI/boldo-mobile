import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:boldo/network/connection_status.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/screens/dashboard/dashboard_screen.dart';
import 'package:boldo/screens/hero/hero_screen.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/constants.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting();
  Intl.defaultLocale = "es";

  await DotEnv().load('.env');

  GestureBinding.instance.resamplingEnabled = true;

  ConnectionStatusSingleton.getInstance().initialize();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool("onboardingCompleted") ?? false;

  initDio(navKey: navKey);

  const storage = FlutterSecureStorage();
  String session = await storage.read(key: "access_token");

  if (kReleaseMode) {
    String sentryDSN = String.fromEnvironment('SENTRY_DSN',
        defaultValue: DotEnv().env['SENTRY_DSN']);
    await SentryFlutter.init(
      (options) {
        options.environment = "production";
        options.dsn = sentryDSN;
      },
    );
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
      (value) => runApp(
          MyApp(onboardingCompleted: onboardingCompleted, session: session)));
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
      debugShowCheckedModeBanner: false,
      navigatorKey: navKey,
      title: 'Boldo',
      theme: boldoTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          boldoTheme.textTheme,
        ),
      ),
      initialRoute: onboardingCompleted ? '/home' : "/onboarding",
      routes: {
        '/onboarding': (context) => HeroScreen(),
        '/home': (context) => DashboardScreen(),
      },
    );
  }
}
