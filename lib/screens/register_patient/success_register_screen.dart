import 'package:boldo/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants.dart';

class SuccessRegisterScreen extends StatefulWidget {
  SuccessRegisterScreen({
    Key key,
  }) : super(key: key);

  @override
  _SuccessRegisterScreenState createState() => _SuccessRegisterScreenState();
}

class _SuccessRegisterScreenState extends State<SuccessRegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(
                    'assets/Logo.svg',
                    semanticsLabel: 'BOLDO Logo',
                    width: 150,
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/booking.svg',
                  height: 300,
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "¡Bienvenido a Boldo!",
                  style: boldoHeadingTextStyle.copyWith(fontSize: 18),
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  width: 300,
                  child: Text(
                    'Accede a los innovadores productos del Ecosistema Boldo',
                    style: boldoSubTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: "/home"),
                            builder: (context) => DashboardScreen(),
                          ),
                        );
                      },
                      child: const Text("Ingresar"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
