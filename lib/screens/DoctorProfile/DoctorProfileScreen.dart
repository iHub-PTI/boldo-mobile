import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants.dart';

class DoctorProfileScreen extends StatefulWidget {
  DoctorProfileScreen({Key key}) : super(key: key);

  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: SvgPicture.asset('assets/Logo.svg',
                semanticsLabel: 'BOLDO Logo'),
          ),
        ),
        body: Background(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 24,
                ),
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
                    'Perfil',
                    style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/DoctorImage.svg',
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      const Text(
                        "Dra. Susan Giménez",
                        style: boldoHeadingTextStyle,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Dermatología",
                        style: boldoHeadingTextStyle.copyWith(
                            color: Constants.otherColor100),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      const Text(
                        "Biografía",
                        style: boldoHeadingTextStyle,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                          "Recibida en la Universidad Nacional de Asunción en Dermatología. Especialización en Dermatología Estética. Miembro de la Asociación LADERM. ",
                          style: boldoSubTextStyle.copyWith(
                              height: 1.5, fontSize: 16)),
                      const SizedBox(
                        height: 24,
                      ),
                      const Text(
                        "Idiomas",
                        style: boldoHeadingTextStyle,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "- Español",
                        style: boldoSubTextStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "- Inglés",
                        style: boldoSubTextStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "- Alemán",
                        style: boldoSubTextStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const Text(
                        "Registro Profesional",
                        style: boldoHeadingTextStyle,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Nro. 45.786 ",
                        style: boldoSubTextStyle.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/decorations/ProfileScreenTopDecoration.svg',
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/decorations/ProfileBottomDecoration.svg',
            ),
          ),
          child,
        ],
      ),
    );
  }
}
