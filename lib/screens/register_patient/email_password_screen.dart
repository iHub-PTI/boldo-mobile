import 'dart:convert';

import 'package:boldo/models/Patient.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/screens/register_patient/success_register_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../network/http.dart';
import '../../constants.dart';

class EmailPasswordScreen extends StatefulWidget {
  final Patient patient;
  EmailPasswordScreen({@required this.patient});

  @override
  _EmailPasswordScreenState createState() => _EmailPasswordScreenState();
}

class _EmailPasswordScreenState extends State<EmailPasswordScreen> {
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          child: SingleChildScrollView(
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
                Text("Email",
                    style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Ingrese su Email';
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
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Text("Confirmar contraseña",
                    style: boldoHeadingTextStyle.copyWith(fontSize: 15)),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Repite tu contraseña';
                    } else if (_passwordController.text != value) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
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
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    hintText: '+595',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(
                  height: 40,
                ),
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
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          try {
                            const storage = FlutterSecureStorage();
                            final _patient = widget.patient.copyWith(
                                email: _emailController.text,
                                password: _passwordController.text,
                                phone: _phoneController.text);
                            Response response = await dioHealthCore.post(
                                "/keycloack/create",
                                data: json.encode(_patient.toJson()));
                            print(response);
                            await storage.write(
                                key: "access_token",
                                value: response.data["access_token"]);
                            await storage.write(
                                key: "refresh_token",
                                value: response.data["refresh_token"]);

                            Provider.of<AuthProvider>(context, listen: false)
                                .setAuthenticated(isAuthenticated: true);
                            // Response responses =
                            //     await dio.get("/profile/patient");
                            // if (responses.data["photoUrl"] != null) {
                            //   final SharedPreferences prefs =
                            //       await SharedPreferences.getInstance();
                            //   await prefs.setString(
                            //       "profile_url", response.data["photoUrl"]);
                            //   await prefs.setString(
                            //       "gender", response.data["gender"]);
                            // }

                            // Provider.of<UtilsProvider>(context, listen: false)
                            //     .setSelectedPageIndex(pageIndex: 0);

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(
                                      name: "/succes_register"),
                                  builder: (context) => SuccessRegisterScreen(),
                                ));
                          } on DioError catch (ex) {
                            print(ex);
                            if (ex.response?.statusCode == 409) {
                              final snackBar = SnackBar(
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${ex.response.data["errorMessage"]}'),
                                    const Icon(Icons.error)
                                  ],
                                ),
                                backgroundColor: Colors.red,
                              );
                              _scaffoldKey.currentState.showSnackBar(snackBar);
                            }
                            if (ex.type == DioErrorType.CONNECT_TIMEOUT) {
                              throw Exception("Connection  Timeout Exception");
                            }
                            throw Exception(ex.message);
                          }
                        }
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
        ),
      ),
    );
  }
}
