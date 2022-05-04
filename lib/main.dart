import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/screens/family/family_tab.dart';
import 'package:boldo/screens/family/tabs/defined_relationship_screen.dart';
import 'package:boldo/screens/family/tabs/familyConnectTransition.dart';
import 'package:boldo/screens/family/tabs/metods_add_family_screen.dart';
import 'package:boldo/screens/hero/hero_screen_v2.dart';
import 'package:boldo/screens/sing_in/sing_in_transition.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
// import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:boldo/network/connection_status.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/screens/dashboard/dashboard_screen.dart';
import 'package:boldo/screens/hero/hero_screen.dart';
import 'package:boldo/constants.dart';

import 'blocs/user_bloc/patient_bloc.dart';
import 'models/MedicalRecord.dart';
import 'models/Patient.dart';
import 'models/User.dart';
import 'models/upload_url_model.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
final Patient patientModel = Patient();
late SharedPreferences prefs;
User user = User();
Patient patient = Patient();
late List<MedicalRecord> allMedicalData;
late XFile? userImageSelected = null;
int selectedPageIndex  = 0;
const storage = FlutterSecureStorage();
late List<Patient> families = [
  /*Patient(
  givenName: "Fidel",
  familyName: "Aguirre",
  gender: "unknown",
  identifier: "1233445",
  relationship: "papa",
  photoUrl: "https://s3-alpha-sig.figma.com/img/9210/fd70/99decdd7aa6b9bf23fff1bc150449738?Expires=1652054400&Signature=ABbH0Fzwd4OhVen3MNLsqhhUrmIkDJ9vJ-i5eOPfTKfBJyXx8LAQQL3jviRhUR1Ncu8pEYKaTAJ8csylZCSIEOTzUDmey2u7-VXygECH9QE-C34VVLJEQK5hCalSLAuq469nZ3TaNkTODmFDCHIbhgMQW9wgswoDg4cal3pBD0cSohGi8frnkergVupuf89wmICfMOsfv4KcLCH6ewy4WJDF00yaH7948uQU8W8jKjhf3EcRSNg6hcY2z0RHnzaL-vQqPwBgjHQuRkopzSyZvzlgtfLTrfBJXKQ~wIPCYWReUxsNshP5gYwkCa0BaO5RAp0ABp4YBvJzhE5oWRDuJQ__&Key-Pair-Id=APKAINTVSUGEWH5XD5UA",
  ),
  Patient(
  givenName: "Fidel",
  familyName: "Aguirre",
  gender: "unknown",
  identifier: "1233445",
  relationship: "abuelo",
  photoUrl: "https://s3-alpha-sig.figma.com/img/9210/fd70/99decdd7aa6b9bf23fff1bc150449738?Expires=1652054400&Signature=ABbH0Fzwd4OhVen3MNLsqhhUrmIkDJ9vJ-i5eOPfTKfBJyXx8LAQQL3jviRhUR1Ncu8pEYKaTAJ8csylZCSIEOTzUDmey2u7-VXygECH9QE-C34VVLJEQK5hCalSLAuq469nZ3TaNkTODmFDCHIbhgMQW9wgswoDg4cal3pBD0cSohGi8frnkergVupuf89wmICfMOsfv4KcLCH6ewy4WJDF00yaH7948uQU8W8jKjhf3EcRSNg6hcY2z0RHnzaL-vQqPwBgjHQuRkopzSyZvzlgtfLTrfBJXKQ~wIPCYWReUxsNshP5gYwkCa0BaO5RAp0ABp4YBvJzhE5oWRDuJQ__&Key-Pair-Id=APKAINTVSUGEWH5XD5UA",
),*/
];
late UploadUrl frontDniUrl;
late UploadUrl backDniUrl;
late UploadUrl userSelfieUrl;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await initializeDateFormatting('es', null);
  Intl.defaultLocale = "es";
  await dotenv.load(fileName: ".env");
  // await dotenv.load(fileName: '.env');

  GestureBinding.instance!.resamplingEnabled = true;

  ConnectionStatusSingleton.getInstance().initialize();

  prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool("onboardingCompleted") ?? false;
  prefs.setBool("isFamily", prefs.getBool("isFamily") ?? false);

  initDio(navKey: navKey);
  initDioSecondaryAccess(navKey: navKey);
  const storage = FlutterSecureStorage();
  String? session = await storage.read(key: "access_token");

  if (kReleaseMode) {
    String sentryDSN = String.fromEnvironment('SENTRY_DSN',
        defaultValue: dotenv.env['SENTRY_DSN']!);
    await SentryFlutter.init(
      (options) {
        options.environment = "production";
        options.dsn = sentryDSN;
      },
    );
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
      (value) => runApp(
          MyApp(onboardingCompleted: onboardingCompleted, session: session??'')));
}

class MyApp extends StatefulWidget {
  final bool onboardingCompleted;
  final String session;
  const MyApp(
      {Key? key, required this.onboardingCompleted, required this.session})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PatientRegisterBloc>(
          create: (BuildContext context) => PatientRegisterBloc(),
        ),
        BlocProvider<PatientBloc>(
          create: (BuildContext context) => PatientBloc(),
        )
      ],
      child: FullApp(onboardingCompleted: widget.onboardingCompleted),
    );
  }
}

class FullApp extends StatelessWidget {
  const FullApp({
    Key? key,
    required this.onboardingCompleted,
  }) : super(key: key);

  final bool onboardingCompleted;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navKey,
      title: 'Boldo',
      theme: boldoTheme,
      initialRoute: onboardingCompleted ? '/SignInSuccess' : "/onboarding",
      routes: {
        '/onboarding': (context) => HeroScreenV2(),
        '/home': (context) => DashboardScreen(),
        '/login': (context) => const LoginWebViewHelper(),
        '/methods' : (context) => const FamilyMetodsAdd(),
        '/familyScreen' : (context) => FamilyScreen(),
        '/defineRelationship' : (context) => DefinedRelationshipScreen(),
        '/familyTransition' : (context) => FamilyConnectTransition(),
        '/SignInSuccess' : (context) => SingInTransition(),
      },
    );
  }
}
