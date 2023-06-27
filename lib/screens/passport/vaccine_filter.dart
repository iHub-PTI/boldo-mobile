import 'package:boldo/constants.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/button_action_helper.dart';
import 'package:boldo/widgets/header_page.dart';
import 'package:boldo/widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../main.dart';

class VaccineFilter extends StatefulWidget {
  VaccineFilter({Key? key}) : super(key:key);

  @override
  State<VaccineFilter> createState() => _VaccineFilterState();
}

class VaccineModel {
  final String name;
  bool status;
  VaccineModel(this.name, {this.status = false});
  @override
  String toString() {
    return "name ${this.name}  status: ${this.status}";
  }
}

class _VaccineFilterState extends State<VaccineFilter> {
  List<VaccineModel> vaccinesList = [
    VaccineModel(chooseAll),
  ];

  List<VaccineModel> vaccineFinded = [];
  bool isChecked = false;

  @override
  void initState() {
    // here we add all the diseases name
    for (var i = 0; i < ((diseaseUserList?.length) ?? 0); i++) {
      // and then, add all elements
      vaccinesList.add(VaccineModel(diseaseUserList![i].diseaseCode));
    }
    vaccineFinded = vaccinesList;
    super.initState();
  }

  checkAction() {
    vaccineFinded.forEach((element) {
      element.status = isChecked == true ? true : false;
    });
    setState(() {});
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<VaccineModel> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = vaccinesList;
    } else {
      results = vaccinesList
          .where((vaccine) =>
              vaccine.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      vaccineFinded = results;
      print(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: CustomWrapper(
        children: [
          // button and label for go to back
          Row(
            children: [
              BackButtonLabel(),
              Expanded(
                child: header("Mis Vacunas", "Vacunas"),
              ),
            ],
          ),
          
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              "Seleccioná las inmunizaciones para generar el pasaporte",
              style: boldoHeadingTextStyle.copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: TextField(
              onChanged: (value) => _runFilter(value),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: 20, bottom: 20),
                hintText: "Buscar",
                suffixIcon: const Icon(
                  Icons.search,
                  color: Constants.extraColor300,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.builder(
                itemCount: vaccineFinded.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: vaccineFinded[index].name == chooseAll ? 0 : 1,
                    color: vaccineFinded[index].name == chooseAll
                        ? Colors.transparent
                        : Colors.white,
                    child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(vaccineFinded[index].name),
                      value: vaccineFinded[index].status,
                      activeColor: Color(0xff424649),
                      checkColor: Colors.white,
                      onChanged: (value) {
                        if (vaccineFinded[index].name == chooseAll) {
                          setState(() {
                            isChecked = value!;
                          });
                          checkAction();
                        } else {
                          setState(() {
                            vaccineFinded[index].status = value!;
                            // vaccineFinded.sort((a, b) {
                            //   if (b.status && a.name != chooseAll ) {
                            //     return 1;
                            //   }
                            //   return -1;
                            // });
                          });
                        }
                      },
                    ),
                  );
                }),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0, right: 8),
                child: ButtonActionHelper(
                  title: "mostrar",
                  svgPath: 'check_white',
                  onTapAction: () {
                    print(vaccineFinded);
                    //this to make sure it's empty
                    vaccineListQR!.clear();
                    // for each vaccine in filter, we search matches with diseaseUserList
                    for (var i = 0; i < vaccineFinded.length; i++) {
                      // to choose only those that are marked in the filter screen
                      if (vaccineFinded[i].status) {
                        for (var j = 0; j < diseaseUserList!.length; j++) {
                          if (vaccineFinded[i].name ==
                              diseaseUserList![j].diseaseCode) {
                            vaccineListQR!.add(diseaseUserList![j]);
                          }
                        }
                      }
                    }
                    Navigator.pushNamed(context, '/user_qr_detail');
                  },
                )),
          ),
        ],
      ),
    );
  }
}
