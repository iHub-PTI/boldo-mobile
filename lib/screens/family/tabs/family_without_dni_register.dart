import 'package:boldo/blocs/family_bloc/dependent_family_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../main.dart';

class WithoutDniFamilyRegister extends StatefulWidget {
  WithoutDniFamilyRegister({Key? key}) : super(key: key);

  @override
  State<WithoutDniFamilyRegister> createState() =>
      _WithoutDniFamilyRegisterState();
}

class UpperCaseTextFormatter implements TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

class _WithoutDniFamilyRegisterState extends State<WithoutDniFamilyRegister> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loadingQuery = false;
  bool _relationLoaded = false;
  final _fecha = TextEditingController();
  String givenName = "";
  String familyName = "";
  String birthDate = "";
  String gender = "";
  String relationShipCode = "";
  List<String> genders = ["género", "femenino", "masculino", "otro"];
  List<String> relations = ["relación"];

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: GestureDetector(
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
                  //await Navigator.pushNamed(context, '/familyTransition');
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.response!),
                      backgroundColor: Colors.redAccent,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                }
                if (state is RelationFailed) {
                  setState(() {
                    _relationLoaded = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.response!),
                      backgroundColor: Colors.redAccent,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Stack(children: [
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
                      ])),
                ),
                Opacity(
                  opacity: 0.2,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                              'assets/images/register_background.png')),
                    ),
                  ),
                ),
                _relationLoaded
                    ? Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: SvgPicture.asset(
                                    'assets/icon/logo_text.svg'),
                              ),
                              const SizedBox(height: 40),
                              TextFormField(
                                decoration:
                                    const InputDecoration(hintText: "Nombre"),
                                keyboardType: TextInputType.name,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z]'))
                                ],
                                onChanged: (value) {
                                  givenName = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Ingrese al menos un nombre";
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                decoration:
                                    const InputDecoration(hintText: "Apellido"),
                                keyboardType: TextInputType.name,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z]'))
                                ],
                                onChanged: (value) {
                                  familyName = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Ingrese al menos un apellido";
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: _fecha,
                                inputFormatters: [
                                  UpperCaseTextFormatter(),
                                  MaskTextInputFormatter(
                                      mask: "##/##/####",
                                      type: MaskAutoCompletionType.eager)
                                ],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Fecha de nacimiento (dd/mm/yyyy)",
                                  suffixIcon: Align(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: SvgPicture.asset(
                                      'assets/icon/calendar.svg',
                                      color: Constants.primaryColor100,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  birthDate = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Ingrese la fecha de nacimiento";
                                  } else {
                                    try {
                                      var inputFormat = DateFormat('dd/MM/yyy');
                                      var outputFormat =
                                          DateFormat('yyyy-MM-dd');
                                      var date1 = inputFormat
                                          .parse(value.toString().trim());
                                      var date2 = outputFormat.format(date1);
                                      birthDate = date2;
                                    } catch (e) {
                                      return 'El formato debe ser "dd/MM/yyyy" ';
                                    }
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField<String>(
                                  value: genders[0],
                                  hint: Text(
                                    "Género",
                                    style: boldoSubTextMediumStyle.copyWith(
                                        color: ConstantsV2.activeText),
                                  ),
                                  dropdownColor:
                                      ConstantsV2.lightGrey.withOpacity(0.5),
                                  style: boldoSubTextMediumStyle.copyWith(
                                      color: Colors.black),
                                  onChanged: (value) {
                                    setState(() {
                                      value == "masculino"
                                          ? gender = "male"
                                          : value == "femenino"
                                              ? gender = "female"
                                              : gender = "other";
                                    });
                                  },
                                  items: genders
                                      .map((gender) => DropdownMenuItem<String>(
                                            child: Text(gender),
                                            value: gender,
                                          ))
                                      .toList(),
                                  isExpanded: true,
                                  validator: (value) {
                                    if (value == null || value == "género") {
                                      return "Seleccione un género";
                                    }
                                  }),
                              const SizedBox(
                                height: 20,
                              ),
                              _relationLoaded
                                  ? DropdownButtonFormField<String>(
                                      value: relations[0],
                                      hint: Text(
                                        "Relación",
                                        style: boldoSubTextMediumStyle.copyWith(
                                            color: ConstantsV2.activeText),
                                      ),
                                      dropdownColor: ConstantsV2.lightGrey
                                          .withOpacity(0.5),
                                      style: boldoSubTextMediumStyle.copyWith(
                                          color: Colors.black),
                                      onChanged: (value) {
                                        setState(() {
                                          relationShipCode = relationTypes.where(
                                              (element) =>
                                                  element.displaySpan == value).toList().first.code!;
                                        });
                                      },
                                      items: relations
                                          .map((relationship) =>
                                              DropdownMenuItem<String>(
                                                child: Text(relationship),
                                                value: relationship,
                                              ))
                                          .toList(),
                                      isExpanded: true,
                                      validator: (value) {
                                        if (value == null ||
                                            value == "relación") {
                                          return "Seleccione la relación que tiene el dependiente";
                                        }
                                      })
                                  : Container(),
                            ],
                          ),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
                _relationLoaded
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: OutlinedButtonTheme(
                                    data: boldoTheme.outlinedButtonTheme,
                                    child: const Text(
                                      'lo haré más tarde',
                                      style:
                                          TextStyle(fontFamily: 'Montserrat'),
                                    )),
                                style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        width: 1.0, color: ConstantsV2.orange)),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    String _identifier =
                                        prefs.getString('identifier') ?? '';
                                    if (_identifier != '') {
                                      BlocProvider.of<FamilyBloc>(context).add(
                                          LinkWithoutCi(
                                              givenName: givenName,
                                              familyName: familyName,
                                              birthDate: birthDate,
                                              gender: gender,
                                              identifier: _identifier,
                                              relationShipCode:
                                                  relationShipCode));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Por favor, intente esta operación desde el perfil principal.'),
                                          backgroundColor: Colors.redAccent,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('siguiente'),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: _loadingQuery
                                          ? Container(
                                              height: 10,
                                              width: 10,
                                              child:
                                                  const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.0,
                                              ))
                                          : SvgPicture.asset(
                                              'assets/icon/arrow-right.svg'),
                                    )
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  maximumSize: const Size(150, 80),
                                  shape: const StadiumBorder(),
                                  primary: ConstantsV2.buttonPrimaryColor100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ]),
            )));
  }
}
