import 'package:boldo/main.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/widgets/custom_form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../blocs/user_bloc/patient_bloc.dart';
import './address_screen.dart';
import './password_reset_screen.dart';
import './components/profile_image.dart';

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
  bool _dataLoaded = true;
  bool _dataLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    editingPatient = Patient.fromJson(patient.toJson());
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

    BlocProvider.of<PatientBloc>(context)
        .add(EditProfile(editingPatient: editingPatient));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is Loading) {
            _dataLoading = true;
          }
          if (state is Success) {
            _dataLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Perfil actualizado!"),
                backgroundColor: ConstantsV2.green,
              ),
            );
          } else if (state is Failed) {
            _dataLoading = false;
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor400),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomFormInput(
                              enable: false,
                              initialValue: editingPatient.givenName,
                              label: "Nombre",
                              validator: (value) => valdiateFirstName(value!),
                              onChanged: (String val) =>
                                  (editingPatient.givenName = val),
                            ),

                            const SizedBox(height: 20),
                            CustomFormInput(
                              enable: false,
                              initialValue: editingPatient.familyName,
                              label: "Apellido",
                              validator: (value) => valdiateLasttName(value!),
                              onChanged: (String val) =>
                                  (editingPatient.familyName = val),
                            ),

                            //CustomDropdown(),
                            const SizedBox(height: 20),
                            CustomFormInput(
                              initialValue: editingPatient.job,
                              secondaryLabel: "Opcional",
                              label: "Ocupación",
                              onChanged: (String val) =>
                                  (editingPatient.job = val),
                            ),

                            const SizedBox(height: 20),
                             const Text(
                              'Sexo',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Constants.extraColor400,
                              ),
                            ),
                            DropdownButtonFormField<String>(
                                value: editingPatient.gender == 'unknown'
                                    ? null
                                    : editingPatient.gender,
                                hint: Text(
                                  "Género",
                                  style: boldoSubTextMediumStyle.copyWith(
                                      color: ConstantsV2.activeText),
                                ),
                                style: boldoSubTextMediumStyle.copyWith(
                                    color: Colors.black),
                                onChanged: null,
                                items: ['male', 'female']
                                    .map((gender) => DropdownMenuItem<String>(
                                          child: Text(gender == 'male'
                                              ? 'Masculino'
                                              : gender == 'female'
                                                  ? "Femenino"
                                                  : "desconocido"),
                                          value: gender,
                                        ))
                                    .toList(),
                                isExpanded: true,
                                ),
                            const SizedBox(height: 20),
                            const Text(
                              'Fecha de nacimiento (dd/mm/yyyy)',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Constants.extraColor400,
                              ),
                            ),
                            const SizedBox(height: 7,),
                             Text(
                              '${ DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(editingPatient.birthDate!))}',
                              style: const TextStyle(
                                // fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Constants.extraColor300,
                              ),
                            ),

                            const SizedBox(height: 20),
                            if (!(prefs.getBool(isFamily)?? false))
                              CustomFormInput(
                                initialValue: editingPatient.email ?? '',
                                label: "Correo electrónico",
                                validator: (value) => validateEmail(value!),
                                onChanged: (String val) =>
                                    (editingPatient.email = val),
                              ),
                            if (!(prefs.getBool(isFamily)?? false))
                              const SizedBox(height: 20),

                            CustomFormInput(
                              initialValue: editingPatient.phone,
                              isPhoneNumber: true,
                              secondaryLabel: "Opcional",
                              label: "Número de teléfono",
                              inputFormatters: [ValidatorInputFormatter()],
                              onChanged: (String val) =>
                                  (editingPatient.phone = val),
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
                                    const Text('Dirección',
                                        style: boldoSubTextStyle)
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                            //TODO: not implemented for dependents
                            if (!(prefs.getBool(isFamily)?? false))
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PasswordResetScreen(),
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
                                      const Text('Contraseña',
                                          style: boldoSubTextStyle)
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                              ),
                            const SizedBox(height: 8),
                            const SizedBox(height: 8),
                            CustomFormButton(
                              loading: _dataLoading,
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
