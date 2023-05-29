import 'dart:io';

import 'package:boldo/blocs/appointmet_bloc/appointmentBloc.dart';
import 'package:boldo/blocs/doctor_more_availability_bloc/doctor_more_availability_bloc.dart';
import 'package:boldo/blocs/doctors_available_bloc/doctors_available_bloc.dart';
import 'package:boldo/blocs/doctors_favorite_bloc/doctors_favorite_bloc.dart';
import 'package:boldo/blocs/family_bloc/dependent_family_bloc.dart';
import 'package:boldo/blocs/homeAppointments_bloc/homeAppointments_bloc.dart';
import 'package:boldo/blocs/homeNews_bloc/homeNews_bloc.dart';
import 'package:boldo/blocs/homeOrganization_bloc/homeOrganization_bloc.dart';
import 'package:boldo/blocs/home_bloc/home_bloc.dart';
import 'package:boldo/blocs/logout_bloc/userLogoutBloc.dart';
import 'package:boldo/blocs/medical_record_bloc/medicalRecordBloc.dart';
import 'package:boldo/blocs/prescriptions_bloc/prescriptionsBloc.dart';
import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/blocs/specializationFilter_bloc/specializationFilter_bloc.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/appointments/pastAppointments_screen.dart';
import 'package:boldo/screens/dashboard/tabs/doctors_tab.dart';
import 'package:boldo/screens/doctor_search/doctors_available.dart';
import 'package:boldo/screens/family/family_tab.dart';
import 'package:boldo/screens/family/tabs/defined_relationship_screen.dart';
import 'package:boldo/screens/family/tabs/familyConnectTransition.dart';
import 'package:boldo/screens/family/tabs/family_change_transition.dart';
import 'package:boldo/screens/family/tabs/family_register_account.dart';
import 'package:boldo/screens/family/tabs/family_without_dni_register.dart';
import 'package:boldo/screens/family/tabs/metods_add_family_screen.dart';
import 'package:boldo/screens/hero/hero_screen_v2.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:boldo/screens/my_studies/my_studies_screen.dart';
import 'package:boldo/screens/passport/user_qr_screen.dart';
import 'package:boldo/screens/prescriptions/prescriptions_screen.dart';
import 'package:boldo/screens/profile/profile_screen.dart';
import 'package:boldo/screens/sing_in/sing_in_transition.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:boldo/network/connection_status.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/screens/dashboard/dashboard_screen.dart';
import 'package:boldo/constants.dart';

import 'blocs/attach_study_order_bloc/attachStudyOrder_bloc.dart';
import 'blocs/doctorFilter_bloc/doctorFilter_bloc.dart';
import 'blocs/doctor_availability_bloc/doctor_availability_bloc.dart';
import 'blocs/doctor_bloc/doctor_bloc.dart';
import 'blocs/doctors_recent_bloc/doctors_recent_bloc.dart';
import 'blocs/passport_bloc/passportBloc.dart';
import 'blocs/prescription_bloc/prescriptionBloc.dart';
import 'blocs/study_order_bloc/studyOrder_bloc.dart';
import 'blocs/user_bloc/patient_bloc.dart';
import 'environment.dart';
import 'firebase_options.dart';
import 'models/MedicalRecord.dart';
import 'models/Organization.dart';
import 'models/Patient.dart';
import 'models/Relationship.dart';
import 'models/User.dart';
import 'models/UserVaccinate.dart';
import 'models/upload_url_model.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
final Patient patientModel = Patient();
late SharedPreferences prefs;
UrlUploadType photoStage = UrlUploadType.frontal;
User user = User();
Patient patient = Patient();
Patient editingPatient = Patient();
late List<MedicalRecord> allMedicalData;
List<UserVaccinate>? diseaseUserList;
// list of vaccinate for generate QR url
List<UserVaccinate>? vaccineListQR = [];
XFile? userImageSelected;
int selectedPageIndex = 0;
List<Organization> organizationsPostulated = [];
const storage = FlutterSecureStorage();
late List<Relationship> relationTypes = [];
late List<Patient> families = [];
late UploadUrl frontDniUrl;
late UploadUrl backDniUrl;
late UploadUrl userSelfieUrl;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // await dotenv.load(fileName: '.env');

  //GestureBinding.instance!.resamplingEnabled = true;
  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  ConnectionStatusSingleton.getInstance().initialize();

  prefs = await SharedPreferences.getInstance();
  prefs.setBool(isFamily, false);

  initDio(navKey: navKey, dio: dio, passport: false);
  initDio(navKey: navKey, dio: dioPassport, passport: true);
  dioByteInstance();
  const storage = FlutterSecureStorage();
  String? session;
  try {
    session = await storage.read(key: "access_token");
  } catch (e) {
    storage.deleteAll();
  }

  if (kReleaseMode) {
    String? sentryDSN = environment.SENTRY_DSN;
    await SentryFlutter.init(
      (options) {
        options.environment = environment.SENTRY_ENV;
        options.dsn = sentryDSN;
      },
    );
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(MyApp(session: session ?? '')));
}

class MyApp extends StatefulWidget {
  final String session;
  const MyApp({Key? key, required this.session}) : super(key: key);

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
          ),
          BlocProvider<FamilyBloc>(
            create: (BuildContext context) => FamilyBloc(),
          ),
          BlocProvider<HomeBloc>(
            create: (BuildContext context) => HomeBloc(),
          ),
          BlocProvider<PrescriptionBloc>(
            create: (BuildContext context) => PrescriptionBloc(),
          ),
          BlocProvider<MyStudiesBloc>(
            create: (BuildContext context) => MyStudiesBloc(),
          ),
          BlocProvider<HomeNewsBloc>(
            create: (BuildContext context) => HomeNewsBloc(),
          ),
          BlocProvider<HomeAppointmentsBloc>(
            create: (BuildContext context) => HomeAppointmentsBloc(),
          ),
          BlocProvider<PassportBloc>(
            create: (BuildContext context)=> PassportBloc(),
          ),
          BlocProvider<StudyOrderBloc>(
            create: (BuildContext context) => StudyOrderBloc(),
          ),
          BlocProvider<AttachStudyOrderBloc>(
            create: (BuildContext context) => AttachStudyOrderBloc(),
          ),
          BlocProvider<UserLogoutBloc>(
              create: (BuildContext context) => UserLogoutBloc()
          ),
          BlocProvider<HomeOrganizationBloc>(
            create: (BuildContext context) => HomeOrganizationBloc(),
          ),
          BlocProvider<DoctorsAvailableBloc>(
            create: (BuildContext context) => DoctorsAvailableBloc(),
          ),
          BlocProvider<DoctorFilterBloc>(
            create: (BuildContext context) => DoctorFilterBloc(),
          ),
          BlocProvider<SpecializationFilterBloc>(
            create: (BuildContext context) => SpecializationFilterBloc(),
          ),
          BlocProvider<DoctorAvailabilityBloc>(
            create: (BuildContext context) => DoctorAvailabilityBloc(),
          ),
          BlocProvider<DoctorMoreAvailabilityBloc>(
            create: (BuildContext context) => DoctorMoreAvailabilityBloc(),
          ),
          BlocProvider<RecentDoctorsBloc>(
            create: (BuildContext context) => RecentDoctorsBloc(),
          ),
          BlocProvider<FavoriteDoctorsBloc>(
            create: (BuildContext context) => FavoriteDoctorsBloc(),
          ),
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
            ChangeNotifierProvider<UtilsProvider>(
                create: (_) => UtilsProvider()),
            ChangeNotifierProvider<AuthProvider>(
                // ignore: unnecessary_null_comparison
                create: (_) =>
                    AuthProvider(widget.session != null ? true : false)),
            ChangeNotifierProvider<DoctorFilterProvider>(create: (_) => DoctorFilterProvider())
          ],
          child: FullApp(onboardingCompleted: widget.session),
        ));
  }
}

class FullApp extends StatelessWidget {
  const FullApp({
    Key? key,
    required this.onboardingCompleted,
  }) : super(key: key);

  final String onboardingCompleted;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("es", 'ES'),
        const Locale('en'),
        const Locale('fr'),
      ],
      debugShowCheckedModeBanner: false,
      navigatorKey: navKey,
      title: 'Boldo',
      theme: boldoTheme,
      initialRoute:
          onboardingCompleted != '' ? '/SignInSuccess' : "/onboarding",
      routes: {
        '/onboarding': (context) => HeroScreenV2(),
        '/home': (context) => DashboardScreen(),
        '/login': (context) => const LoginWebViewHelper(),
        '/methods' : (context) => const FamilyMetodsAdd(),
        '/familyScreen' : (context) => FamilyScreen(),
        '/defineRelationship' : (context) => DefinedRelationshipScreen(),
        '/familyTransition' : (context) => FamilyConnectTransition(),
        '/SignInSuccess' : (context) => SingInTransition(),
        '/FamilyTransition' : (context) => FamilyTransition(),
        '/familyDniRegister' : (context) => DniFamilyRegister(),
        '/my_studies' : (context) => MyStudies(),
        '/doctorsTab' : (context) => DoctorsTab(),
        '/pastAppointmentsScreen' : (context) => const PastAppointmentsScreen(),
        '/prescriptionsScreen' : (context) => const PrescriptionsScreen(),
        '/user_qr_detail': (context) => UserQrDetail(),
        '/familyConnectTransition': (context) => FamilyConnectTransition(),
        '/familyWithoutDniRegister': (context) => WithoutDniFamilyRegister(),
        '/profileScreen': (context) => const ProfileScreen(),
      },
    );
  }
}
