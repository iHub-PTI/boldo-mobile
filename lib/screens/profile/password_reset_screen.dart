import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../widgets/wrapper.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_form_input.dart';
import '../../network/http.dart';
import '../../constants.dart';

import '../../utils/form_utils.dart';

class PasswordResetScreen extends StatefulWidget {
  PasswordResetScreen({Key key}) : super(key: key);

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  bool _validate = false;
  bool _loading = false;
  String oldPassword, newPassword, repeatNewPassword;
  String errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> _onUpdatePassword() async {
    if (!_formKey.currentState.validate()) {
      setState(() {
        _validate = true;
      });
      return;
    }

    _formKey.currentState.save();
    setState(() {
      errorMessage = "";
      _loading = true;
    });

    try {
      // Response response = await dio.post("/profile/patient", data: {
      //   "givenName": givenName,
      //   "familyName": familyName,
      //   "birthDate": birthDate,
      //   "job": job,
      //   "gender": gender,
      //   "email": email,
      //   "phone": phone
      // });
      //print(response);
      setState(() {
        _loading = false;
      });
    } on DioError catch (err) {
      print(err);
      setState(() {
        errorMessage = "Something went wrong. Please try again later.";
        _loading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        errorMessage = "Something went wrong. Please try again later.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      children: [
        const SizedBox(
          height: 20,
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
            'Contraseña',
            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
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
                      oldPassword = val;
                    });
                  },
                ),
                const SizedBox(
                  height: 48,
                ),
                CustomFormInput(
                  label: "Contraseña nueva",
                  customSVGIcon: "assets/icon/eyeoff.svg",
                  validator: validatePassword,
                  obscureText: true,
                  onChanged: (String val) => setState(() => newPassword = val),
                  changeValueCallback: (String val) {
                    setState(() {
                      newPassword = val;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomFormInput(
                  label: "Confirmar contraseña nueva",
                  customSVGIcon: "assets/icon/eyeoff.svg",
                  validator: (pass2) =>
                      validatePasswordConfirmation(pass2, newPassword),
                  obscureText: true,
                  changeValueCallback: (String val) {
                    setState(() {
                      repeatNewPassword = val;
                    });
                  },
                ),
                const SizedBox(
                  height: 56,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Constants.primaryColor500,
                    ),
                    onPressed: _loading ? null : _onUpdatePassword,
                    child: const Text("Guardar"),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
