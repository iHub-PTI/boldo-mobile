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
  const FilterScreen({Key key}) : super(key: key);

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
                                                      specialization.id);
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
                const BuildLanguages(),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Constants.primaryColor500,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text("Guardar"),
                  ),
                ),
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
}

class BuildLanguages extends StatelessWidget {
  const BuildLanguages({Key key}) : super(key: key);

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
                    item["name"],
                    style: boldoHeadingTextStyle.copyWith(fontSize: 14),
                  ),
                  value: data.contains(item["name"]),
                  activeColor: Constants.primaryColor500,

                  onChanged: (newValue) {
                    if (newValue) {
                      Provider.of<UtilsProvider>(context, listen: false)
                          .addLanguageValue(item["name"]);
                    } else {
                      //remove
                      Provider.of<UtilsProvider>(context, listen: false)
                          .removeLanguageValue(item["name"]);
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
