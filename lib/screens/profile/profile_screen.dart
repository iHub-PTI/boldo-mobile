import 'package:boldo/widgets/custom_form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './address_screen.dart';
import './password_reset_screen.dart';
import './components/profile_image.dart';

import './actions/sharedActions.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_form_input.dart';
import '../../widgets/wrapper.dart';

import '../../utils/form_utils.dart';

import '../../provider/user_provider.dart';

import '../../network/http.dart';
import '../../constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _validate = false;
  bool loading = false;
  bool _dataLoaded = false;
  bool _dataLoading = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      Response response = await dio.get("/profile/patient");

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
        city: response.data["city"],
        email: response.data["email"],
        phone: response.data["phone"],
        notify: true,
      );
      Provider.of<UserProvider>(context, listen: false)
          .clearProfileFormMessages();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("profile_url", response.data["photoUrl"]??'');
      await prefs.setString("gender", response.data["gender"]);
      setState(() {
        _dataLoading = false;
        _dataLoaded = true;
      });
    } on DioError catch (exception, stackTrace) {
      print(exception);
      setState(() {
        _dataLoading = false;
        _dataLoaded = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);
      setState(() {
        _dataLoading = false;
        _dataLoaded = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _validate = true;
      });
      return;
    }

    _formKey.currentState!.save();

    Provider.of<UserProvider>(context, listen: false)
        .clearProfileFormMessages();
    setState(() {
      loading = true;
    });
    Map<String, String> updateResponse = await updateProfile(context: context);
    Provider.of<UserProvider>(context, listen: false).updateProfileEditMessages(
        updateResponse["successMessage"]!, updateResponse["errorMessage"]!);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return CustomWrapper(children: [
      const SizedBox(height: 24),
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
      if (_dataLoading)
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 48.0),
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
              backgroundColor: Constants.primaryColor600,
            ),
          ),
        ),
      if (!_dataLoading && !_dataLoaded)
        const Center(
          child: Text(
            "Algo salió mal. Por favor, inténtalo de nuevo más tarde.",
            style: TextStyle(
              fontSize: 14,
              color: Constants.otherColor100,
            ),
          ),
        ),
      if (!_dataLoading && _dataLoaded)
        Column(
          children: [
            const SizedBox(height: 24),
            const Center(child: ProfileImage()),
            const SizedBox(height: 24),
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
                          initialValue: data,
                          label: "Nombre",
                          validator: valdiateFirstName,
                          onChanged: (String val) => userProvider.setUserData(
                            givenName: val,
                          ),
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getGivenName ?? '',
                    ),

                    const SizedBox(height: 20),
                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          initialValue: data,
                          label: "Apellido",
                          validator: valdiateLasttName,
                          onChanged: (String val) => userProvider.setUserData(
                            familyName: val,
                          ),
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getFamilyName?? '',
                    ),

                    //CustomDropdown(),
                    const SizedBox(height: 20),
                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          initialValue: data,
                          secondaryLabel: "Opcional",
                          label: "Ocupación",
                          onChanged: (String val) =>
                              userProvider.setUserData(job: val),
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getJob??'',
                    ),

                    const SizedBox(height: 20),
                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        String selectedvalue = data;
                        List<Map<String, String>> itemsList = [
                          {"title": "Masculino", "value": 'male'},
                          {"title": "Femenino", "value": 'female'},
                          {"title": "Otro", "value": 'other'}
                        ];
                        if (selectedvalue == "unknown") {
                          itemsList.add({
                            "title": "Selecciona tu género",
                            "value": 'unknown'
                          });
                        }
                        return CustomDropdown(
                          label: "Género",
                          selectedValue: selectedvalue,
                          itemsList: itemsList,
                          onChanged: (String val) {
                            userProvider.setUserData(gender: val, notify: true);
                          },
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getGender??'',
                    ),

                    const SizedBox(height: 20),

                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          label: "Fecha de nacimiento",
                          initialValue: DateFormat('dd.MM.yyyy')
                              .format(DateTime.parse(data)),
                          validator: null,
                          isDateTime: true,
                          onChanged: (String val) {
                            var inputFormat = DateFormat("yyyy-MM-dd");
                            var date1 = inputFormat.format(DateTime.parse(val));

                            userProvider.setUserData(
                              birthDate: date1,
                            );
                          },
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getBirthDate??'',
                    ),

                    const SizedBox(height: 20),
                    Selector<UserProvider, String>(
                      builder: (_, data, __) {
                        return CustomFormInput(
                          initialValue: data,
                          label: "Correo electrónico",
                          validator: validateEmail,
                          onChanged: (String val) =>
                              userProvider.setUserData(email: val),
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getEmail??'',
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
                          onChanged: (String val) =>
                              userProvider.setUserData(phone: val),
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getPhone??'',
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
                            const SizedBox(width: 10),
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
                            const SizedBox(width: 10),
                            const Text('Contraseña', style: boldoSubTextStyle)
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      child: Column(
                        children: [
                          if (userProvider.profileEditErrorMessage != null)
                            Text(
                              userProvider.profileEditErrorMessage!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Constants.otherColor100,
                              ),
                            ),
                          if (userProvider.profileEditSuccessMessage != null)
                            Text(
                              userProvider.profileEditSuccessMessage!,
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
                      actionCallback: _updateProfile,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        )
    ]);
  }
}
