import 'package:boldo/screens/register_patient/success_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';

class EmailPasswordScreen extends StatefulWidget {
  EmailPasswordScreen({Key key}) : super(key: key);

  @override
  _EmailPasswordScreenState createState() => _EmailPasswordScreenState();
}

class _EmailPasswordScreenState extends State<EmailPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(17.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 17,
                    ),
                  ),
                  Text("Crear Cuenta",
                      style: boldoHeadingTextStyle.copyWith(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text("Email", style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
            const SizedBox(
              height: 10,
            ),
            const TextField(),
            const SizedBox(
              height: 20,
            ),
            Text("Contraseña",
                style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
            const SizedBox(
              height: 10,
            ),
            const TextField(
              obscureText: true,
            ),
            const SizedBox(
              height: 20,
            ),
            Text("Confirmar contraseña",
                style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
            const SizedBox(
              height: 10,
            ),
            const TextField(
              obscureText: true,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text("Nùmero de teléfono",
                    style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
                const Spacer(),
                Text("Opcional",
                    style: boldoSubTextStyle.copyWith(fontSize: 15)),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const TextField(
              decoration: InputDecoration(
                hintText: '+595',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(
              height: 40,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text("Al registrarse, aceptas nuestros ",
            //         style: boldoSubTextStyle.copyWith(fontSize: 13)),
            //     Text("téminos de servicios",
            //         style: boldoSubTextStyle.copyWith(
            //             fontSize: 13, color: Colors.red[200])),
            //     Text(" y ", style: boldoSubTextStyle.copyWith(fontSize: 13)),
            //     Text("politicas de privacidad",
            //         style: boldoSubTextStyle.copyWith(
            //             fontSize: 13, color: Colors.red[200])),
            //   ],
            // ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: "Al registrarse, aceptas nuestros ",
                        style: boldoSubTextStyle.copyWith(fontSize: 13)),
                    TextSpan(
                        text: "téminos de servicios",
                        style: TextStyle(
                            color: Colors.red[200],
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: " y ",
                        style: boldoSubTextStyle.copyWith(fontSize: 13)),
                    TextSpan(
                        text: "politicas de privacidad",
                        style: TextStyle(
                            color: Colors.red[200],
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
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
                        settings: const RouteSettings(name: "/register_email"),
                        builder: (context) => SuccessRegisterScreen(),
                      ),
                    );
                  },
                  child: const Text("Crear Cuenta en Boldo"),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text("Paso 2 de 2",
                  style: boldoSubTextStyle.copyWith(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
