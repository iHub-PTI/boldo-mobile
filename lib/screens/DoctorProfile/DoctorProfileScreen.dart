import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                SizedBox(
                  height: 24,
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: Color(0xff364152),
                  ),
                  label: Text(
                    'Perfil',
                    style: TextStyle(
                        color: Color(0xff364152),
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/DoctorImage.svg',
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "Dra. Susan Giménez",
                        style: TextStyle(
                            color: Color(0xff364152),
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Dermatología",
                        style: TextStyle(
                            color: Color(0xffDF6D51),
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Biografía",
                        style: TextStyle(
                            color: Color(0xff364152),
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Recibida en la Universidad Nacional de Asunción en Dermatología. Especialización en Dermatología Estética. Miembro de la Asociación LADERM. ",
                        style: TextStyle(
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.normal,
                            height: 1.5,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Idiomas",
                        style: TextStyle(
                            color: Color(0xff364152),
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "- Español",
                        style: TextStyle(
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.normal,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "- Inglés",
                        style: TextStyle(
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.normal,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "- Alemán",
                        style: TextStyle(
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.normal,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Registro Profesional",
                        style: TextStyle(
                            color: Color(0xff364152),
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Nro. 45.786 ",
                        style: TextStyle(
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.normal,
                            fontSize: 16),
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
