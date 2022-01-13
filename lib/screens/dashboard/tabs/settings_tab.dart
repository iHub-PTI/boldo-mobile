import 'dart:convert';

import 'package:boldo/screens/about/about_screen.dart';
import 'package:boldo/screens/contact/contact_screen.dart';
import 'package:boldo/screens/terms_of_services/terms_of_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boldo/provider/user_provider.dart';
import 'package:boldo/screens/profile/profile_screen.dart';
import '../../../widgets/wrapper.dart';
import '../../../provider/auth_provider.dart';
import '../../../constants.dart';

class SettingsTab extends StatefulWidget {
  SettingsTab({Key? key}) : super(key: key);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  'Configuraciones',
                  textAlign: TextAlign.start,
                  style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                leading: SizedBox(
                  height: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/profile.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Mi perfil', style: boldoSubTextStyle)
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsOfServices(),
                    ),
                  );
                },
                leading: SizedBox(
                  height: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/termsAndConditions.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Términos de servicio',
                          style: boldoSubTextStyle)
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
              // ListTile(
              //   onTap: () {},
              //   leading: SizedBox(
              //     height: double.infinity,
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         SvgPicture.asset(
              //           'assets/icon/privacyPolicy.svg',
              //         ),
              //         const SizedBox(
              //           width: 10,
              //         ),
              //         const Text('Política de privacidad',
              //             style: boldoSubTextStyle)
              //       ],
              //     ),
              //   ),
              //   trailing: const Icon(Icons.chevron_right),
              // ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const About(),
                    ),
                  );
                },
                leading: SizedBox(
                  height: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/information.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Acerca de Boldo', style: boldoSubTextStyle)
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Contact(),
                    ),
                  );
                },
                leading: SizedBox(
                  height: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/headphones.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Centro de Ayuda', style: boldoSubTextStyle)
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
              const SizedBox(
                height: 24,
              ),
              ListTile(
                onTap: () async {
                  try {
                    String baseUrlKeyCloack = String.fromEnvironment(
                        'KEYCLOAK_REALM_ADDRESS',
                        defaultValue: dotenv.env['KEYCLOAK_REALM_ADDRESS']!);

                    const storage = FlutterSecureStorage();
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? refreshToken =
                        await storage.read(key: "refresh_token");
                    Map<String, dynamic> body = {
                      "refresh_token": refreshToken,
                      "client_id": "boldo-patient"
                    };
                    var url = Uri.parse(
                       "$baseUrlKeyCloack/protocol/openid-connect/logout");
                     await http.post(url,
                        body: body,
                        headers: {
                          "Content-Type": "application/x-www-form-urlencoded"
                        },
                        encoding: Encoding.getByName("utf-8"));
                    Provider.of<AuthProvider>(context, listen: false)
                        .setAuthenticated(isAuthenticated: false);
                    Provider.of<UserProvider>(context, listen: false)
                        .clearProvider();
                    await prefs.setBool("onboardingCompleted", false);
                    await storage.deleteAll();
                    await prefs.clear();

                    Navigator.pushNamed(context, '/onboarding');
                  } on DioError catch (exception, stackTrace) {
                    print(exception);

                    await Sentry.captureException(
                      exception,
                      stackTrace: stackTrace,
                    );
                  } catch (exception, stackTrace) {
                    print(exception);
                    await Sentry.captureException(
                      exception,
                      stackTrace: stackTrace,
                    );
                  }
                },
                leading: SizedBox(
                  height: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/powersettings.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Cerrar sesión', style: boldoSubTextStyle)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
