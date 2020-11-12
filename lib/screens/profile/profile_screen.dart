import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';

import './address_screen.dart';
import './password_reset_screen.dart';
import './components/profile_image.dart';

import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_form_input.dart';
import '../../widgets/wrapper.dart';

import '../../utils/form_utils.dart';

import '../../network/http.dart';
import '../../constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _validate = false;
  bool _loading = false;

  String givenName, familyName, birthDate, job, gender, email, phone;

  String _errorMessage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    gender = "unknown";
    birthDate = "1980-01-01";
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState.validate()) {
      setState(() {
        _validate = true;
      });
      return;
    }

    _formKey.currentState.save();
    setState(() {
      _errorMessage = null;
      _loading = true;
    });

    try {
      Response response = await dio.post("/profile/patient", data: {
        "givenName": givenName,
        "familyName": familyName,
        "birthDate": birthDate,
        "job": job,
        "gender": gender,
        "email": email,
        "phone": phone
      });
      print(response);
      setState(() {
        _loading = false;
      });
    } on DioError catch (err) {
      print(err);
      setState(() {
        _errorMessage = "Something went wrong. Please try again later.";
        _loading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _errorMessage = "Something went wrong. Please try again later.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomWrapper(children: [
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
          'Mi perfil',
          style: boldoHeadingTextStyle.copyWith(fontSize: 20),
        ),
      ),
      const SizedBox(
        height: 24,
      ),
      const Center(child: ProfileImage()),
      const SizedBox(
        height: 24,
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
                label: "Nombre",
                validator: valdiateFirstName,
                changeValueCallback: (String val) {
                  setState(() {
                    givenName = val;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomFormInput(
                label: "Apellido",
                validator: valdiateLasttName,
                changeValueCallback: (String val) {
                  setState(() {
                    familyName = val;
                  });
                },
              ),

              //CustomDropdown(),
              const SizedBox(
                height: 20,
              ),
              CustomFormInput(
                secondaryLabel: "Opcional",
                label: "Ocupación",
                validator: null,
                changeValueCallback: (String val) {
                  setState(() {
                    job = val;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomDropdown(
                label: "Género",
                selectedValue: gender,
                itemsList: [
                  {"title": "Male", "value": 'male'},
                  {"title": "Female", "value": 'female'},
                  {"title": "Other", "value": 'other'},
                  {"title": "Select your gender", "value": 'unknown'},
                ],
                onChanged: (String val) {
                  setState(() {
                    gender = val;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomFormInput(
                label: "Fecha de nacimiento",
                initialValue: birthDate,
                validator: null,
                isDateTime: true,
                changeValueCallback: (String val) {
                  setState(() {
                    birthDate = val;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),
              CustomFormInput(
                label: "Correo electrónico",
                validator: validateEmail,
                changeValueCallback: (String val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomFormInput(
                isPhoneNumber: true,
                secondaryLabel: "Opcional",
                label: "Número de teléfono",
                inputFormatters: [ValidatorInputFormatter()],
                changeValueCallback: (String val) {
                  setState(() {
                    phone = val;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressScreen(),
                    ),
                  );
                },
                leading: SizedBox(
                  height: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/marker.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Dirección', style: boldoSubTextStyle)
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasswordResetScreen(),
                    ),
                  );
                },
                leading: SizedBox(
                  height: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/key.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Contraseña', style: boldoSubTextStyle)
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
              const SizedBox(
                height: 24,
              ),
              if (_errorMessage != null)
                Text(
                  "$_errorMessage",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Constants.otherColor100,
                  ),
                ),
              const SizedBox(
                height: 12,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Constants.primaryColor500,
                  ),
                  onPressed: _loading ? null : _updateProfile,
                  child: const Text("Guardar"),
                ),
              )
            ],
          ),
        ),
      ),
    ]);
  }
}
