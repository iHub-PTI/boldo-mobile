import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import './address_screen.dart';
import './password_reset_screen.dart';
import './components/profile_image.dart';

import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_form_input.dart';
import '../../widgets/wrapper.dart';

import '../../utils/form_utils.dart';

import '../../provider/user_provider.dart';

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
  bool _initialLoad = true;
  String _errorMessage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      Response response = await dio.get("/profile/patient");
      print(response);
      Provider.of<UserProvider>(context, listen: false).setUserData(
        addressDescription: response.data["addressDescription"],
        job: response.data["job"],
        neighborhood: response.data["neighborhood"],
        street: response.data["street"],
        photoUrl: response.data["photoUrl"],
        birthDate: response.data["birthDate"],
        givenName: response.data["givenName"],
        familyName: response.data["familyName"],
        gender: response.data["gender"],
        email: response.data["email"],
        phone: response.data["phone"],
        notify: true,
      );

      setState(() {
        _initialLoad = false;
      });
    } on DioError catch (err) {
      print(err);
      setState(() {
        _errorMessage = "Something went wrong. Please try again later.";
        _initialLoad = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _errorMessage = "Something went wrong. Please try again later.";
        _initialLoad = false;
      });
    }
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
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
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
      if (_initialLoad)
        const Center(
            child: Padding(
          padding: EdgeInsets.only(top: 48.0),
          child: CircularProgressIndicator(),
        )),
      if (!_initialLoad)
        Column(
          children: [
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
                autovalidateMode: _validate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                key: _formKey,
                child: Column(
                  children: [
                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          initialValue: data ?? "",
                          label: "Nombre",
                          validator: valdiateFirstName,
                          changeValueCallback: (String val) {
                            userProvider.setUserData(givenName: val);
                          },
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getGivenName,
                    ),

                    const SizedBox(height: 20),
                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          initialValue: data ?? "",
                          label: "Apellido",
                          validator: valdiateLasttName,
                          changeValueCallback: (String val) {
                            userProvider.setUserData(familyName: val);
                          },
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getFamilyName,
                    ),

                    //CustomDropdown(),
                    const SizedBox(height: 20),
                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          initialValue: data ?? "",
                          secondaryLabel: "Opcional",
                          label: "Ocupación",
                          changeValueCallback: (String val) {
                            userProvider.setUserData(job: val);
                          },
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getJob,
                    ),

                    const SizedBox(height: 20),
                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomDropdown(
                          label: "Género",
                          selectedValue: data ?? 'unknown',
                          itemsList: [
                            {"title": "Male", "value": 'male'},
                            {"title": "Female", "value": 'female'},
                            {"title": "Other", "value": 'other'},
                            {"title": "Select your gender", "value": 'unknown'},
                          ],
                          onChanged: (String val) {
                            userProvider.setUserData(gender: val, notify: true);
                          },
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getGender,
                    ),

                    const SizedBox(height: 20),

                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          label: "Fecha de nacimiento",
                          initialValue: data,
                          validator: null,
                          isDateTime: true,
                          changeValueCallback: (String val) {
                            userProvider.setUserData(birthDate: val);
                          },
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getBirthDate,
                    ),

                    const SizedBox(height: 20),
                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          initialValue: data,
                          label: "Correo electrónico",
                          validator: validateEmail,
                          changeValueCallback: (String val) {
                            userProvider.setUserData(email: val);
                          },
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getEmail,
                    ),

                    const SizedBox(height: 20),

                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          initialValue: data,
                          isPhoneNumber: true,
                          secondaryLabel: "Opcional",
                          label: "Número de teléfono",
                          inputFormatters: [ValidatorInputFormatter()],
                          changeValueCallback: (String val) {
                            userProvider.setUserData(phone: val);
                          },
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getPhone,
                    ),

                    const SizedBox(height: 20),
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
          ],
        )
    ]);
  }
}
