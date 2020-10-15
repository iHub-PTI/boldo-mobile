import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../screens/Dashboard/DashboardScreen.dart';
import '../../constant.dart';

class BookingFinalScreen extends StatefulWidget {
  BookingFinalScreen({
    Key key,
  }) : super(key: key);

  @override
  _BookingFinalScreenState createState() => _BookingFinalScreenState();
}

class _BookingFinalScreenState extends State<BookingFinalScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SvgPicture.asset('assets/Logo.svg',
                  semanticsLabel: 'BOLDO Logo'),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: [
                    Text(
                      "¡Su consulta ha sido agendada!",
                      style: boldoSubTextStyle,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: boldoDarkPrimaryLighterColor,
                        ),
                        onPressed: null,
                        child: const Text("Ver reserva"),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      width: double.infinity,
                      child: OutlinedButton(
                        //  style: style1,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DashboardScreen()),
                          );
                        },
                        child: Text(
                          'Ir a Inicio',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 14),
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
