import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../main.dart';


class SignUpBasicInfo extends StatelessWidget {
  SignUpBasicInfo({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration( // Background linear gradient
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color> [
                  ConstantsV2.primaryColor100,
                  ConstantsV2.primaryColor200,
                  ConstantsV2.primaryColor300,
                ],
                stops: <double> [
                  ConstantsV2.primaryStop100,
                  ConstantsV2.primaryStop200,
                  ConstantsV2.primaryStop300,
                ]
              )
            ),
          ),
          Opacity(
            opacity: 0.2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/register_background.png')
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: SvgPicture.asset('assets/icon/logo_text.svg'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: "Nombre"),
                    onChanged: (value){
                      user.givenName = value;
                    },
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "Ingrese un nombre";
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: "Apellido"),
                    onChanged: (value){
                      user.familyName = value;
                    },
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "Ingrese un apellido";
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
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
                    onChanged: (value){
                      user.birthDate = value;
                    },
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "Ingrese la fecha de nacimiento";
                      } else {
                        try {
                          var inputFormat = DateFormat('dd/MM/yyy');
                          var outputFormat = DateFormat('yyyy-MM-dd');
                          var date1 = inputFormat.parse(value.toString().trim());
                          var date2 = outputFormat.format(date1);
                          user.birthDate = date2;
                        }catch (e){
                          return 'El formato debe ser "dd/MM/yyyy" ';
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    decoration: const InputDecoration(hintText: "Cédula"),
                    onChanged: (value){
                      user.identifier = value;
                    },
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "Ingrese una cedula";
                      }  else {
                        try {
                          var _identifier = int.parse(value);
                          user.identifier = value;
                        }catch (e){
                          return 'Ingrese una cédula válida';
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DropdownButtonFormField<String>(
                      value: user.relationshipDisplaySpan,
                      hint: Text(
                        "Género",
                        style: boldoSubTextMediumStyle.copyWith(
                            color: ConstantsV2.activeText
                        ),
                      ),
                      dropdownColor: ConstantsV2.lightGrey.withOpacity(0.5),
                      style: boldoSubTextMediumStyle.copyWith(color: Colors.black),
                      onChanged: (value) {
                        user.gender = value!;
                      },
                      items: ['male', 'female']
                          .map((relationship) => DropdownMenuItem<String>(
                        child: Text(relationship),
                        value: relationship,
                      )).toList(),
                      isExpanded: true,
                      validator: (value){
                        if(value == null){
                          return "Selecciona un género";
                        }
                      }
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton (
                      onPressed: () async {
                        if(_formKey.currentState!.validate()){
                          user.isNew = true;
                          await Navigator.pushNamed(context, '/familyTransition');
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('siguiente'),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SvgPicture.asset('assets/icon/arrow-right.svg'),
                          )
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        primary: ConstantsV2.buttonPrimaryColor100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]
      )

    );
  }
}