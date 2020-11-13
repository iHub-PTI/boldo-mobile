import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../widgets/wrapper.dart';
import '../../widgets/custom_form_input.dart';
import '../../provider/user_provider.dart';
import '../../constants.dart';

import '../../network/http.dart';

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
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      Response response = await dio.post("/profile/patient", data: {
        "givenName": userProvider.getGivenName,
        "familyName": userProvider.getFamilyName,
        "birthDate": userProvider.getBirthDate,
        "job": userProvider.getJob,
        "gender": userProvider.getGender,
        "email": userProvider.getEmail,
        "phone": userProvider.getPhone,
        "photoUrl": userProvider.getPhotoUrl,
        "street": userProvider.getStreet,
        "neighborhood": userProvider.getNeighborhood,
        "city": userProvider.getCity,
        "addressDescription": userProvider.getAddressDescription,
      });

      print(response);
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
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
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
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return CustomFormInput(
                      initialValue: data ?? "",
                      label: "Calle",
                      secondaryLabel: "Opcional",
                      changeValueCallback: (String val) {
                        userProvider.setUserData(street: val);
                      },
                    );
                  },
                  selector: (buildContext, userProvider) =>
                      userProvider.getStreet,
                ),
                const SizedBox(height: 20),
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return CustomFormInput(
                      initialValue: data ?? "",
                      label: "Barrio",
                      secondaryLabel: "Opcional",
                      changeValueCallback: (String val) {
                        userProvider.setUserData(neighborhood: val);
                      },
                    );
                  },
                  selector: (buildContext, userProvider) =>
                      userProvider.getNeighborhood,
                ),
                const SizedBox(height: 20),
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return CustomFormInput(
                      initialValue: data ?? "",
                      label: "Ciudad",
                      secondaryLabel: "Opcional",
                      changeValueCallback: (String val) {
                        userProvider.setUserData(city: val);
                      },
                    );
                  },
                  selector: (buildContext, userProvider) =>
                      userProvider.getCity,
                ),
                const SizedBox(height: 20),
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return CustomFormInput(
                      initialValue: data ?? "",
                      maxLines: 6,
                      label: "Referencia",
                      secondaryLabel: "Opcional",
                      changeValueCallback: (String val) {
                        userProvider.setUserData(addressDescription: val);
                      },
                    );
                  },
                  selector: (buildContext, userProvider) =>
                      userProvider.getAddressDescription,
                ),
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
