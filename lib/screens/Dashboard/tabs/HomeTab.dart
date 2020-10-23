import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leadingWidth: double.infinity,
        toolbarHeight: 110,
        flexibleSpace: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 70,
                  width: 70,
                  child: SvgPicture.asset(
                    'assets/images/DoctorImage.svg',
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "¡Bienvenido!",
                      style: boldoHeadingTextStyle.copyWith(
                          fontSize: 24, color: Constants.primaryColor500),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const Text("Lunes, 14 de septiembre"),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Agrega tu primera cita",
                style: TextStyle(
                    color: Colors.grey[850],
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 240,
                child: Text(
                  "Consulta la lista de doctores y programá tu primera cita",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                      fontSize: 17),
                ),
              )
            ]),
      ),
    );
  }
}
