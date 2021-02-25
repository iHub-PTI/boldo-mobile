import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';

class EsentialDataScreen extends StatefulWidget {
  EsentialDataScreen({Key key}) : super(key: key);

  @override
  _EsentialDataScreenState createState() => _EsentialDataScreenState();
}

class _EsentialDataScreenState extends State<EsentialDataScreen> {
  bool _manSelected = true;
  bool _girlSelected = false;
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
            Text("Cédula de identidad",
                style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
            const SizedBox(
              height: 10,
            ),
            const TextField(),
            const SizedBox(
              height: 20,
            ),
            Text("Nombre", style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
            const SizedBox(
              height: 10,
            ),
            const TextField(),
            const SizedBox(
              height: 20,
            ),
            Text("Apellido",
                style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
            const SizedBox(
              height: 10,
            ),
            const TextField(),
            const SizedBox(
              height: 20,
            ),
            Text("Sexo", style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _manSelected = !_manSelected;
                        if (_manSelected == true) _girlSelected = false;
                      });
                    },
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: _manSelected
                              ? Border.all(
                                  width: 4, color: Constants.primaryColor500)
                              : Border.all(width: 1, color: Colors.grey)),
                      child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container()),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text("Masculino",
                      style: boldoHeadingTextStyle.copyWith(fontSize: 15))
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _girlSelected = !_girlSelected;
                        if (_girlSelected == true) _manSelected = false;
                      });
                    },
                    child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: _girlSelected
                                ? Border.all(
                                    width: 4, color: Constants.primaryColor500)
                                : Border.all(width: 1, color: Colors.grey)),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(),
                        )),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text("Femenino",
                      style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Siguiente"),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: Text("Paso 1 de 2",
                  style: boldoSubTextStyle.copyWith(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
