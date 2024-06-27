import 'dart:ui';

import 'package:boldo/blocs/family_bloc/dependent_family_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class WithoutDniFamilyRegister extends StatefulWidget {
  const WithoutDniFamilyRegister({super.key});

  @override
  State<WithoutDniFamilyRegister> createState() =>
      _WithoutDniFamilyRegisterState();
}

class UpperCaseTextFormatter implements TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _WithoutDniFamilyRegisterState extends State<WithoutDniFamilyRegister> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loadingQuery = false;
  bool _relationLoaded = false;
  final _fecha = TextEditingController();
  final _nameController = TextEditingController();
  final _familyNameController = TextEditingController();
  String givenName = '';
  String familyName = '';
  String birthDate = '';
  String gender = '';
  String relation = '';
  String? genderSelected;
  String? relationSelected;
  List<String> genders = ['femenino', 'masculino'];
  List<String> relations = [];

  @override
  void initState() {
    // TODO: implement initState
    // query all the time. This prevents skipping changes in the backend
    BlocProvider.of<FamilyBloc>(context).add(GetRelationShipCodes());
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _fecha.dispose();
    _nameController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  Future<void> _showMyDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: const Text('Atención!'),
            content: const Text(
              'Esta operación debe realizarse desde el perfil principal. Si el error persiste, por favor reinicie su sesión.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Entiendo'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: BlocListener<FamilyBloc, FamilyState>(
          listener: (context, state) async {
            if (state is Loading) {
              setState(() {
                _loadingQuery = true;
              });
            }
            if (state is RelationLoading) {
              setState(() {
                _relationLoaded = false;
              });
            }
            if (state is Success) {
              setState(() {
                _loadingQuery = false;
              });
              BlocProvider.of<FamilyBloc>(context).add(GetFamilyList());
              await emitSnackBar(
                context: context,
                text: dependentSuccessAdded,
                status: ActionStatus.Success,
              );
              await Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
            if (state is RelationSuccess) {
              for (var i = 0; i < relationTypes.length; i++) {
                relations.add(relationTypes[i].displaySpan!);
              }
              setState(() {
                _relationLoaded = true;
              });
            }
            if (state is Failed) {
              setState(() {
                _loadingQuery = false;
              });
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text(state.response!),
              //     backgroundColor: Colors.redAccent,
              //     duration: const Duration(seconds: 2),
              //   ),
              // );
            }
            if (state is RelationFailed) {
              setState(() {
                _relationLoaded = false;
              });
              await emitSnackBar(
                context: context,
                text: state.response,
                status: ActionStatus.Fail,
              );
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  // Background linear gradient
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: <Color>[
                      ConstantsV2.primaryColor100,
                      ConstantsV2.primaryColor200,
                      ConstantsV2.primaryColor300,
                    ],
                    stops: <double>[
                      ConstantsV2.primaryStop100,
                      ConstantsV2.primaryStop200,
                      ConstantsV2.primaryStop300,
                    ],
                  ),
                ),
              ),
              Opacity(
                opacity: 0.2,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        'assets/images/register_background.png',
                      ),
                    ),
                  ),
                ),
              ),
              if (_relationLoaded)
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                BackButtonLabel(
                                  iconType: BackIcon.backClose,
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: SvgPicture.asset(
                                'assets/icon/logo_text.svg',
                              ),
                            ),
                            const SizedBox(height: 40),
                            TextFormField(
                              controller: _nameController,
                              style: boldoSubTextMediumStyle.copyWith(
                                color: ConstantsV2.activeText,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nombre',
                                hintStyle: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.activeText,
                                ),
                                labelStyle: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.activeText,
                                ),
                              ),
                              keyboardType: TextInputType.name,
                              onChanged: (value) {
                                givenName = value;
                              },
                              validator: (value) {
                                //remove unnecessary spaces
                                value = value?.trimLeft().trimRight() ?? '';
                                _nameController.text =
                                    value.trimLeft().trimRight() ?? '';
                                if (value.isEmpty) {
                                  return 'Ingrese al menos un nombre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _familyNameController,
                              style: boldoSubTextMediumStyle.copyWith(
                                color: ConstantsV2.activeText,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Apellido',
                                hintStyle: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.activeText,
                                ),
                                labelStyle: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.activeText,
                                ),
                              ),
                              keyboardType: TextInputType.name,
                              onChanged: (value) {
                                familyName = value;
                              },
                              validator: (value) {
                                //remove unnecessary spaces
                                value = value?.trimLeft().trimRight() ?? '';
                                _familyNameController.text =
                                    value.trimLeft().trimRight() ?? '';
                                if (value.isEmpty) {
                                  return 'Ingrese al menos un apellido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _fecha,
                              inputFormatters: [
                                const UpperCaseTextFormatter(),
                                DateTextFormatter(),
                              ],
                              keyboardType: TextInputType.number,
                              style: boldoSubTextMediumStyle.copyWith(
                                color: ConstantsV2.activeText,
                              ),
                              decoration: InputDecoration(
                                hintText: DateFormat('dd/MM/yyyy')
                                    .format(DateTime.now()),
                                hintStyle: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.activeText,
                                ),
                                labelStyle: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.activeText,
                                ),
                                labelText: 'Fecha de nacimiento (dd/mm/yyyy)',
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    'assets/icon/calendar.svg',
                                    fit: BoxFit.scaleDown,
                                    color: ConstantsV2.activeText,
                                    width: 4,
                                    alignment: Alignment.centerRight,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                birthDate = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese la fecha de nacimiento';
                                } else {
                                  try {
                                    final inputFormat = DateFormat('dd/MM/yyy');
                                    final outputFormat =
                                        DateFormat('yyyy-MM-dd');
                                    final date1 =
                                        inputFormat.parseStrict(value.trim());

                                    if (date1.isBefore(minDate)) {
                                      throw Failure(
                                        'Fecha inferior al minimo ${inputFormat.format(minDate)}',
                                      );
                                    } else if (date1.isAfter(DateTime.now())) {
                                      throw Failure(
                                        'Fecha superior a la actual',
                                      );
                                    }
                                    final date2 = outputFormat.format(date1);
                                    birthDate = date2;
                                  } on Failure catch (e) {
                                    return e.message;
                                  } catch (e) {
                                    return 'El formato debe ser "dd/mm/yyyy" ';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            DropdownButtonFormField<String>(
                              value: genderSelected,
                              hint: Text(
                                'Sexo',
                                style: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.activeText,
                                ),
                              ),
                              style: boldoSubTextMediumStyle.copyWith(
                                color: Colors.black,
                              ),
                              dropdownColor: Colors.white.withOpacity(0.85),
                              onChanged: (value) {
                                setState(() {
                                  genderSelected = value;
                                  value == 'masculino'
                                      ? gender = 'male'
                                      : value == 'femenino'
                                          ? gender = 'female'
                                          : gender = 'other';
                                });
                              },
                              items: genders
                                  .map(
                                    (gender) => DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    ),
                                  )
                                  .toList(),
                              isExpanded: true,
                              validator: (value) {
                                if (value == null || value == 'sexo') {
                                  return 'Seleccione el sexo';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (_relationLoaded)
                              DropdownButtonFormField<String>(
                                value: relationSelected,
                                hint: Text(
                                  'Relación',
                                  style: boldoSubTextMediumStyle.copyWith(
                                    color: ConstantsV2.activeText,
                                  ),
                                ),
                                style: boldoSubTextMediumStyle.copyWith(
                                  color: Colors.black,
                                ),
                                dropdownColor: Colors.white.withOpacity(0.85),
                                onChanged: (value) {
                                  setState(() {
                                    relationSelected = value;
                                    // save to send
                                    relation = relationTypes
                                        .where(
                                          (element) =>
                                              element.displaySpan == value,
                                        )
                                        .toList()
                                        .first
                                        .code!;
                                  });
                                },
                                items: relations
                                    .map(
                                      (relationship) =>
                                          DropdownMenuItem<String>(
                                        value: relationship,
                                        child: Text(relationship),
                                      ),
                                    )
                                    .toList(),
                                isExpanded: true,
                                validator: (value) {
                                  if (value == null || value == 'relación') {
                                    return 'Seleccione la relación que tiene el dependiente';
                                  }
                                  return null;
                                },
                              )
                            else
                              Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                loadingStatus(),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        if (_relationLoaded)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: ConstantsV2.orange,
                      ),
                    ),
                    child: OutlinedButtonTheme(
                      data: boldoTheme.outlinedButtonTheme,
                      child: Text(
                        'Lo haré más tarde',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: MediaQuery.of(context).size.width >= 400
                              ? 16
                              : 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final identifier = prefs.getString('identifier') ?? '';
                        if (identifier != '') {
                          BlocProvider.of<FamilyBloc>(context).add(
                            LinkWithoutCi(
                              givenName: givenName,
                              familyName: familyName,
                              birthDate: birthDate,
                              gender: gender,
                              identifier: identifier,
                              relationShipCode: relation,
                            ),
                          );
                        } else {
                          await _showMyDialog();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      maximumSize: Size(
                        MediaQuery.of(context).size.width >= 400 ? 150 : 120,
                        80,
                      ),
                      shape: const StadiumBorder(),
                      backgroundColor: ConstantsV2.buttonPrimaryColor100,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirmar',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width >= 400
                                ? 16
                                : 12,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _loadingQuery
                              ? const SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/icon/arrow-right.svg',
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          loadingStatus(),
      ],
    );
  }
}
