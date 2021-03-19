import 'package:boldo/models/Patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _manSelected = true;
  bool _girlSelected = false;
  var _ciController = TextEditingController();
  var _nameController = TextEditingController();
  var _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 70,
              ),
              Text("Iniciar Sesión",
                  style: boldoHeadingTextStyle.copyWith(fontSize: 20)),
              const SizedBox(
                height: 40,
              ),
              Text("Cédula de identidad",
                  style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _ciController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Ingrese su número de Cedula';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Text("Contraseña",
                  style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                obscureText: true,
                // controller: _passwordController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Ingrese su contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text("¿Has olvidado tu contraseña?",
                    style: boldoSubTextStyle.copyWith(
                        fontSize: 15, color: Colors.red[200])),
              ),
              const SizedBox(
                height: 40,
              ),
              Center(
                child: SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     settings:
                        //         const RouteSettings(name: "/register_email"),
                        //     builder: (context) => EmailPasswordScreen(
                        //       patient: Patient(
                        //           username: _ciController.text,
                        //           firstName: _nameController.text,
                        //           lastName: _lastNameController.text,
                        //           gender: _manSelected == true ? 'M' : 'F'),
                        //     ),
                        //   ),
                        // );
                      }
                    },
                    child: const Text("Iniciar Sesión"),
                  ),
                ),
              ),
              const SizedBox(
                height: 200,
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Text("¿Usuario nuevo?",
                    style: boldoSubTextStyle.copyWith(fontSize: 15)),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text("Regístrate",
                    style: boldoSubTextStyle.copyWith(
                        fontSize: 15, color: Colors.red[200])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
