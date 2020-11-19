import 'package:boldo/screens/filter/splecialities_filter_screen.dart';
import 'package:boldo/widgets/custom_form_input.dart';
import 'package:boldo/widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      children: [
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
            'Filtros',
            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SpecialitiesFilterScreen(),
                    ),
                  );
                },
                child: Container(
                  color: Colors.transparent,
                  child: IgnorePointer(
                    ignoring: true,
                    child: CustomFormInput(
                      label: "Especialidad",
                      changeValueCallback: null,
                      customSVGIcon: 'assets/icon/selector.svg',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              BuildLanguages(),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Constants.primaryColor500,
                  ),
                  onPressed: () {
                    print("apply");
                  },
                  child: const Text("Guardar"),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    print("clear");
                  },
                  child: const Text(
                    "Limpiar Filtros",
                    style: TextStyle(color: Constants.extraColor400),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class BuildLanguages extends StatefulWidget {
  BuildLanguages({Key key}) : super(key: key);

  @override
  _BuildLanguagesState createState() => _BuildLanguagesState();
}

class _BuildLanguagesState extends State<BuildLanguages> {
  List<String> defaultLanguagesList = [
    "Español",
    "Guaraní",
    "Inglés",
    "Portugués"
  ];
  List<String> _selectedLanguagesList = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Idiomas",
          style: boldoHeadingTextStyle.copyWith(fontSize: 14),
        ),
        for (String value in defaultLanguagesList)
          Theme(
            data: ThemeData(unselectedWidgetColor: Constants.extraColor200),
            child: CheckboxListTile(
              title: Text(
                value,
                style: boldoHeadingTextStyle.copyWith(fontSize: 14),
              ),
              value: _selectedLanguagesList.contains(value),
              activeColor: Constants.primaryColor500,

              onChanged: (newValue) {
                if (newValue) {
                  //add
                  _selectedLanguagesList.add(value);
                } else {
                  //remove
                  _selectedLanguagesList.remove(value);
                }
                setState(() {});
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          ),
      ],
    );
  }
}
