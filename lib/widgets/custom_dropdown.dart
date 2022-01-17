import 'package:flutter/material.dart';

import '../constants.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String selectedValue;
  final List<Map<String, String>> itemsList;
  final Function(String) onChanged;
  const CustomDropdown(
      {Key? key,
      required this.label,
      required this.selectedValue,
      required this.itemsList,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Constants.extraColor400),
          ),
          const SizedBox(height: 3),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Constants.extraColor200),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            width: double.infinity,
            height: 50,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                style: const TextStyle(
                    color: Constants.extraColor300, fontSize: 16),
                isDense: false,
                itemHeight: 50,
                isExpanded: false,

                icon: const Icon(Icons.keyboard_arrow_down),
                // iconSize: 24,
                iconEnabledColor: Constants.extraColor300,
                iconDisabledColor: Constants.extraColor300,
                elevation: 16,
                onChanged: (string) { 
                  onChanged(string!);
                },
                // onChanged: onChanged,
                items: itemsList
                    .map<DropdownMenuItem<String>>((Map<String, String> value) {
                  return DropdownMenuItem<String>(
                    value: value["value"],
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        value["title"]!,
                      ),
                    ),
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
