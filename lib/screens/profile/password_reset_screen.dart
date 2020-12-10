import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../widgets/wrapper.dart';

import '../../widgets/custom_form_button.dart';
import '../../widgets/custom_form_input.dart';
import '../../constants.dart';
import '../../network/http.dart';
import '../../utils/form_utils.dart';

class PasswordResetScreen extends StatefulWidget {
  PasswordResetScreen({Key key}) : super(key: key);

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  bool _validate = false;
  bool loading = false;
  String _currentPassword, _newPassword, _confirmation;
  String _errorMessage;
  String _successMessage;
  final _formKey = GlobalKey<FormState>();

  Future<void> _updatePassword() async {
    if (!_formKey.currentState.validate()) {
      setState(() {
        _validate = true;
      });
      return;
    }

    _formKey.currentState.save();
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      loading = true;
    });

    try {
      String baseUrlKeyCloack = String.fromEnvironment('KEYCLOAK_REALM_ADDRESS',
          defaultValue: DotEnv().env['KEYCLOAK_REALM_ADDRESS']);
      dio.options.baseUrl = baseUrlKeyCloack;

      await dio.post(
        "/account/credentials/password",
        data: {
          "currentPassword": _currentPassword,
          "newPassword": _newPassword,
          "confirmation": _confirmation
        },
      );

      setState(() {
        _successMessage = "¡La contraseña ha sido actualizada!";
        loading = false;
      });
    } on DioError catch (err) {
      print(err);

      setState(() {
        _errorMessage = err.response.statusCode == 400
            ? "Contraseña incorrecta"
            : "Algo salió mal. Por favor, inténtalo de nuevo más tarde.";
        loading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _errorMessage =
            "Algo salió mal. Por favor, inténtalo de nuevo más tarde.";
        loading = false;
      });
    }
    String baseUrlServer = String.fromEnvironment('SERVER_ADDRESS',
        defaultValue: DotEnv().env['SERVER_ADDRESS']);
    dio.options.baseUrl = baseUrlServer;
  }

  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      children: [
        const SizedBox(height: 20),
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
            'Contraseña',
            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            autovalidateMode:
                _validate ? AutovalidateMode.always : AutovalidateMode.disabled,
            key: _formKey,
            child: Column(
              children: [
                CustomFormInput(
                  label: "Contraseña actual",
                  customSVGIcon: "assets/icon/eyeoff.svg",
                  validator: validatePassword,
                  obscureText: true,
                  changeValueCallback: (String val) {
                    setState(() {
                      _currentPassword = val;
                    });
                  },
                ),
                const SizedBox(height: 48),
                CustomFormInput(
                  label: "Contraseña nueva",
                  customSVGIcon: "assets/icon/eyeoff.svg",
                  validator: validatePassword,
                  obscureText: true,
                  onChanged: (String val) => setState(() => _newPassword = val),
                  changeValueCallback: (String val) {
                    setState(() {
                      _newPassword = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomFormInput(
                  label: "Confirmar contraseña nueva",
                  customSVGIcon: "assets/icon/eyeoff.svg",
                  validator: (pass2) =>
                      validatePasswordConfirmation(pass2, _newPassword),
                  obscureText: true,
                  changeValueCallback: (String val) {
                    setState(() {
                      _confirmation = val;
                    });
                  },
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 18,
                  child: Column(
                    children: [
                      if (_errorMessage != null)
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Constants.otherColor100,
                          ),
                        ),
                      if (_successMessage != null)
                        Text(
                          _successMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Constants.primaryColor600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                CustomFormButton(
                  loading: loading,
                  text: "Guardar",
                  actionCallback: _updatePassword,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
