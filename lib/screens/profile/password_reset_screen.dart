import 'package:boldo/environment.dart';
import 'package:boldo/main.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../widgets/wrapper.dart';

import '../../widgets/custom_form_button.dart';
import '../../widgets/custom_form_input.dart';
import '../../constants.dart';
import '../../network/http.dart';
import '../../utils/form_utils.dart';

class PasswordResetScreen extends StatefulWidget {
  PasswordResetScreen({Key? key}) : super(key: key);

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  bool _validate = false;
  bool loading = false;
  String? _currentPassword, _newPassword, _confirmation;
  String? _errorMessage;
  String? _successMessage;
  final _formKey = GlobalKey<FormState>();

  // flag for password field
  bool _obscureText = true;

  // function for password field
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // flag for password field
  bool _obscureText1 = true;

  // function for password field
  void _toggle1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  // flag for repeat password field
  bool _obscureText2 = true;

  // function for repeat password field
  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  Widget obscureTextToggle(){
    return GestureDetector(
      onTap: _toggle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SvgPicture.asset(
          "assets/icon/eyeoff.svg",
          color: Constants.extraColor300,
        ),
      ),
    );
  }

  Widget obscureText1Toggle(){
    return GestureDetector(
      onTap: _toggle1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SvgPicture.asset(
          "assets/icon/eyeoff.svg",
          color: Constants.extraColor300,
        ),
      ),
    );
  }

  Widget obscureText2Toggle(){
    return GestureDetector(
      onTap: _toggle2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SvgPicture.asset(
          "assets/icon/eyeoff.svg",
          color: Constants.extraColor300,
        ),
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _validate = true;
      });
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      loading = true;
    });

    try {
      String baseUrlKeyCloack = environment.KEYCLOAK_REALM_ADDRESS;
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
    } on DioError catch(exception, stackTrace){
      await Sentry.captureMessage(
        exception.toString(),
        params: [
          {
            "path": exception.requestOptions.path,
            "data": exception.requestOptions.data,
            "patient": prefs.getString("userId"),
            "dependentId": patient.id,
            "responseError": exception.response,
            'access_token': await storage.read(key: 'access_token')
          },
          stackTrace
        ],
      );
      setState(() {
        _errorMessage = exception.response!.statusCode == 400
            ? "Contraseña incorrecta"
            : "Algo salió mal. Por favor, inténtalo de nuevo más tarde.";
        loading = false;
      });
    } catch (exception, stackTrace) {
      print(exception);
      setState(() {
        _errorMessage =
            "Algo salió mal. Por favor, inténtalo de nuevo más tarde.";
        loading = false;
      });
      await Sentry.captureMessage(
          exception.toString(),
          params: [
            {
              'patient': prefs.getString("userId"),
              'access_token': await storage.read(key: 'access_token')
            },
            stackTrace
          ]
      );
    }
    String baseUrlServer = environment.SERVER_ADDRESS;
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
                  customIcon: obscureTextToggle(),
                  validator: (value) => validatePassword(value!),
                  obscureText: _obscureText,
                  onChanged: (String val) => setState(() => _currentPassword = val),
                  
                ),
                const SizedBox(height: 48),
                CustomFormInput(
                  label: "Contraseña nueva",
                  customIcon: obscureText1Toggle(),
                  validator: (value) => validatePassword(value!),
                  obscureText: _obscureText1,
                  onChanged: (String val) => setState(() => _newPassword = val),
                ),
                const SizedBox(height: 20),
                CustomFormInput(
                  label: "Confirmar contraseña nueva",
                  customIcon: obscureText2Toggle(),
                  validator: (pass2) =>
                      validatePasswordConfirmation(pass2, _newPassword),
                  obscureText: _obscureText2,
                    onChanged: (String val) => setState(() => _confirmation = val),
                  
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 18,
                  child: Column(
                    children: [
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Constants.otherColor100,
                          ),
                        ),
                      if (_successMessage != null)
                        Text(
                          _successMessage!,
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
