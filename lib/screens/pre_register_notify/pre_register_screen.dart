import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/wrapper.dart';

import '../../constants.dart';

class PreRegisterScreen extends StatefulWidget {
  const PreRegisterScreen({Key? key}) : super(key: key);

  @override
  _PreRegisterScreenState createState() => _PreRegisterScreenState();
}

class _PreRegisterScreenState extends State<PreRegisterScreen> {
  bool value = false;
  @override
  void initState() {
    super.initState();
  }

  Widget confirmButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.10000000149011612),
                  offset: Offset(0, 1),
                  blurRadius: 3)
            ],
            color: Color.fromRGBO(101, 207, 211, 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text(
            'Confirmar',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 1),
                fontFamily: 'Inter',
                fontSize: 17,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
                height: 1.1428571428571428),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomWrapper(
        children: [
          SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      size: 25,
                      color: Constants.extraColor400,
                    ),
                    label: Text(
                      'Antes de continuar',
                      style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Boldo se encuentra en un período de prueba controlado.\n\n'
                            'Antes de registrarte, tenga en cuenta que por el momento, el servicio está disponible solamente para algunos pacientes en un conjunto de centros asistenciales.\n\n'
                            'En breve, extenderemos el servicio a todo público.\n\n',
                        style: TextStyle(
                          color: Color.fromRGBO(54, 65, 82, 1),
                          fontFamily: 'PT Serif',
                          fontSize: 17,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                          height: 1.5,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                              'Siga con el proceso de registro solamente si recibió indicación de su médico.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        backgroundColor: ConstantsV2.orange,
        label: Container(
            child: Row(
              children: [
                const Text(
                  'continuar',
                ),
                const SizedBox(
                  width: 8,
                ),
                const Icon(
                  Icons.arrow_forward_ios_sharp
                ),
              ],
            )),
      ),
    );
  }
}
