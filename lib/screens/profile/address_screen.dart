import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import '../../widgets/wrapper.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_form_input.dart';

import '../../constants.dart';

class AddressScreen extends StatefulWidget {
  AddressScreen({Key key}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _validate = false;
  bool _loading = false;
  String street, neighborhood, city, addressDescription;
  String errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> _updateLocation() async {
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
            'Dirección',
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
                  label: "Calle",
                  secondaryLabel: "Opcional",
                  changeValueCallback: (String val) {
                    setState(() {
                      street = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomFormInput(
                    label: "Barrio",
                    secondaryLabel: "Opcional",
                    changeValueCallback: (String val) {
                      setState(() {
                        neighborhood = val;
                      });
                    }),
                const SizedBox(height: 20),
                CustomFormInput(
                    label: "Ciudad",
                    secondaryLabel: "Opcional",
                    changeValueCallback: (String val) {
                      setState(() {
                        city = val;
                      });
                    }),
                const SizedBox(height: 20),
                CustomFormInput(
                    maxLines: 6,
                    label: "Referencia",
                    secondaryLabel: "Opcional",
                    changeValueCallback: (String val) {
                      setState(() {
                        addressDescription = val;
                      });
                    }),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Constants.primaryColor500,
                    ),
                    onPressed: _loading ? null : _updateLocation,
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
