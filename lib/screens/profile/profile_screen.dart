import 'package:boldo/main.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/widgets/custom_form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../blocs/user_bloc/patient_bloc.dart';
import './address_screen.dart';
import './password_reset_screen.dart';
import './components/profile_image.dart';

import './actions/sharedActions.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_form_input.dart';
import '../../widgets/wrapper.dart';

import '../../utils/form_utils.dart';

import '../../provider/user_provider.dart';

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

      editingPatient = Patient.fromJson(patient.toJson());
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
    Map<String, String>? updateResponse = await updateProfile(context: context);
    Provider.of<UserProvider>(context, listen: false).updateProfileEditMessages(
        updateResponse["successMessage"]??'', updateResponse["errorMessage"]??'');

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PatientBloc, PatientState>(
        listener: (context, state){
          if(state is Success) {
            setState(() {

            });
          }else if(state is Failed){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response!),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: BlocBuilder<PatientBloc, PatientState>(
          builder: (context, state) {
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
                    const Center(child: ProfileImageEdit()),
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
                            CustomFormInput(
                              initialValue: editingPatient.givenName,
                              label: "Nombre",
                              validator: (value) => valdiateFirstName(value!),
                              onChanged: (String val) => (editingPatient.givenName = val
                              ),
                            ),


                            const SizedBox(height: 20),
                            CustomFormInput(
                              initialValue: editingPatient.familyName,
                              label: "Apellido",
                              validator: (value) => valdiateLasttName(value!),
                              onChanged: (String val) => (
                                editingPatient.familyName = val
                              ),
                            ),

                            //CustomDropdown(),
                            const SizedBox(height: 20),
                            CustomFormInput(
                              initialValue: editingPatient.job,
                              secondaryLabel: "Opcional",
                              label: "Ocupación",
                              onChanged: (String val) => (editingPatient.job = val),
                            ),

                            const SizedBox(height: 20),
                            Builder(
                              builder: (context) {
                                String selectedvalue = editingPatient.gender?? 'unknown';
                                List<Map<String, String>> itemsList = [
                                  {"title": "Masculino", "value": 'male'},
                                  {"title": "Femenino", "value": 'female'}
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
                                  onChanged: (String val) =>
                                    (editingPatient.gender = val),
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            TextFormField(
                              initialValue: DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(editingPatient.birthDate!)),
                              inputFormatters: [MaskTextInputFormatter(mask: "##/##/####")],
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese la fecha de nacimiento';
                                } else {
                                  try {
                                    var inputFormat = DateFormat('dd/MM/yyyy');
                                    var outputFormat = DateFormat('yyyy-MM-dd');
                                    var date1 = inputFormat
                                        .parse(value.toString().trim());
                                    var date2 = outputFormat.format(date1);
                                    editingPatient.birthDate = date2;
                                  } catch (e) {
                                    return "El formato de la fecha debe ser (dd/MM/yyyy)";
                                  }
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: "31/12/2020",
                                labelText: "Fecha de nacimiento (dd/mm/yyyy)",
                              )
                            ),

                            const SizedBox(height: 20),
                            if(!prefs.getBool("isFamily")!)
                              CustomFormInput(
                                initialValue: editingPatient.email?? '',
                                label: "Correo electrónico",
                                validator: (value) => validateEmail(value!),
                                onChanged: (String val) => (editingPatient.email = val),
                              ),
                            if(!prefs.getBool("isFamily")!)
                              const SizedBox(height: 20),

                            CustomFormInput(
                              initialValue: editingPatient.phone,
                              isPhoneNumber: true,
                              secondaryLabel: "Opcional",
                              label: "Número de teléfono",
                              inputFormatters: [ValidatorInputFormatter()],
                              onChanged: (String val) => (editingPatient.phone = val),
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
                            //TODO: not implemented for dependents
                            if(!prefs.getBool("isFamily")!)
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
                                  if (state is Failed)
                                    Text(
                                      state.response?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Constants.otherColor100,
                                      ),
                                    ),
                                  if (state is Success)
                                    const Text(
                                      "Actualizado exitosamente",
                                      style: TextStyle(
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
          },
        ),
      ),
    );
  }
}
