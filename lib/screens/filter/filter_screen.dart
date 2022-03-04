import 'package:boldo/models/Specialization.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/filter/splecialities_filter_screen.dart';
import 'package:boldo/widgets/custom_form_input.dart';
import 'package:boldo/widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/languages.dart';
import '../../constants.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<UtilsProvider>(context, listen: false).clearFilters();
        return true;
      },
      child: CustomWrapper(
        children: [
          const SizedBox(
            height: 24,
          ),
          TextButton.icon(
            onPressed: () {
              Provider.of<UtilsProvider>(context, listen: false).clearFilters();
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
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const SpecialitiesFilterScreen()),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      ignoring: true,
                      child: CustomFormInput(
                        label: "Especialidad",
                        customSVGIcon: 'assets/icon/selector.svg',
                      ),
                    ),
                  ),
                ),
                Selector<UtilsProvider, List<Specialization>>(
                  selector: (buildContext, userProvider) =>
                      userProvider.getListOfSpecializations,
                  builder: (_, listOfSpecializations, __) {
                    if (listOfSpecializations.length == 0)
                      return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 10.0, // gap between adjacent chips
                          runSpacing: 8, // gap between lines
                          children: <Widget>[
                            for (Specialization specialization
                                in listOfSpecializations)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xffF3FAF7),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                      color: Constants.primaryColor600),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${specialization.description}',
                                        style: boldoHeadingTextStyle.copyWith(
                                            fontSize: 12,
                                            color: Constants.primaryColor600),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Provider.of<UtilsProvider>(context,
                                                  listen: false)
                                              .removeSpecialization(
                                                  specializationId:
                                                      specialization.id!);
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Constants.primaryColor600,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                ModalityCheck(),
                const BuildLanguages(),
                const SizedBox(height: 36),
                dynamicFilterButton(context),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Provider.of<UtilsProvider>(context, listen: false)
                          .clearFilters();
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
      ),
    );
  }

  Widget dynamicFilterButton(BuildContext context) {
    switch (
        Provider.of<UtilsProvider>(context, listen: true).getFilterCounter) {
      case -1:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Constants.grayColor500,
            ),
            onPressed: null,
            child: const Text("Aplique algún filtro primero"),
          ),
        );

      case 0:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Constants.grayColor500,
            ),
            onPressed: null,
            child: const Text("No hay coincidencias"),
          ),
        );

      default:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Constants.primaryColor500,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(
                "Mostrar ${Provider.of<UtilsProvider>(context, listen: true).getFilterCounter > 0 ? '(' + Provider.of<UtilsProvider>(context, listen: false).getFilterCounter.toString() + ') coincidencia(s)' : ''}"),
          ),
        );
    }
  }
}

class BuildLanguages extends StatelessWidget {
  const BuildLanguages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Idiomas",
          style: boldoHeadingTextStyle.copyWith(fontSize: 14),
        ),
        for (Map<String, String> item in defaultLanguagesList)
          Theme(
            data: ThemeData(unselectedWidgetColor: Constants.extraColor200),
            child: Selector<UtilsProvider, List<String>>(
              selector: (buildContext, utilsProvider) =>
                  utilsProvider.getListOfLanguages,
              builder: (_, data, __) {
                return CheckboxListTile(
                  title: Text(
                    item["name"]!,
                    style: boldoHeadingTextStyle.copyWith(fontSize: 14),
                  ),
                  value: data.contains(item["value"]),
                  activeColor: Constants.primaryColor500,

                  onChanged: (newValue) {
                    if (newValue!) {
                      Provider.of<UtilsProvider>(context, listen: false)
                          .addLanguageValue(item["value"]!);
                    } else {
                      //remove
                      Provider.of<UtilsProvider>(context, listen: false)
                          .removeLanguageValue(item["value"]!);
                    }
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                );
              },
            ),
          ),
      ],
    );
  }
}

class ModalityCheck extends StatefulWidget {
  @override
  ModalityCheckState createState() => ModalityCheckState();
}

class ModalityCheckState extends State<ModalityCheck> {
  @override
  Widget build(BuildContext context) {
    Map<String, bool> values = {
      'Remoto (en linea)':
          Provider.of<UtilsProvider>(context, listen: true).isAppoinmentOnline,
      'Presencial':
          Provider.of<UtilsProvider>(context, listen: true).isAppoinmentInPerson
    };
    return Container(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Modalidad",
            style: boldoHeadingTextStyle.copyWith(fontSize: 14),
          ),
          Expanded(
            child: Theme(
              data: ThemeData(unselectedWidgetColor: Constants.extraColor200),
              child: ListView(
                children: values.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(
                      key,
                      style: boldoHeadingTextStyle.copyWith(fontSize: 14),
                    ),
                    value: values[key]!,
                    onChanged: (bool? value) {
                      setState(() {
                        values[key] = value!;
                        bool inPerson = false;
                        bool remote = false;
                        values.forEach((key, value) {
                          if (key == 'Presencial') {
                            inPerson = value;
                          } else {
                            remote = value;
                          }
                        });
                        Provider.of<UtilsProvider>(context, listen: false)
                            .setVirtualRemoteStatus(inPerson, remote);
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Constants.primaryColor500,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
