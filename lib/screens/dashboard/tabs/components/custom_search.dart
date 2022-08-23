import 'dart:async';
import 'package:boldo/constants.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:flutter/material.dart';

import 'package:boldo/widgets/custom_form_input.dart';
import 'package:provider/provider.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({Key? key, required this.changeTextCallback})
      : super(key: key);
  final Function(String text) changeTextCallback;

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return CustomFormInput(
      label: "",
      initialValue: Provider.of<UtilsProvider>(context, listen: false).getFilterText,
      onChanged: (String val) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          widget.changeTextCallback(val);
        });
      },
      customIcon: const Icon(
        Icons.search,
        color: Constants.grayColor500,
      ),
    );
  }
}
