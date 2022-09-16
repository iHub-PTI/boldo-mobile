import 'package:boldo/screens/hero/hero_screen_v2.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

class PreRegisterSuccess extends StatefulWidget {
  const PreRegisterSuccess({Key? key}) : super(key: key);

  @override
  _PreRegisterSuccessState createState() => _PreRegisterSuccessState();
}

class _PreRegisterSuccessState extends State<PreRegisterSuccess> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top:30.0),
            child: Container(
              height: 80,
              child: SvgPicture.asset(
                'assets/images/banner.svg',
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  '¡Pre registro completo!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'Recibirás una notificación una vez que tu cuenta esté habilitada.',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 17,
                        color: Color(0xff13A5A9)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
                child: RichText(
                  text: const TextSpan(
                    text: 'Una vez que el personal de ',
                    style: TextStyle(
                        color: Color.fromRGBO(54, 65, 82, 1),
                        fontFamily: 'PT Serif',
                        fontSize: 17,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                        height: 1.5),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'La fundación Tesâi',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              ' valide tus datos podrás acceder a la lista de médicos disponibles. También podrás marcar y asistir a consultas remotas, todo desde la app.',
                          style: TextStyle(fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HeroScreenV2()),
                    );
                  },
                  child: const Text("Entendido"),
                ),
              ),
            ))
      ]),
    );
  }
}
