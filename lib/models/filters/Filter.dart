import 'package:flutter/material.dart';

abstract class Filter {
  bool get ifFiltered;

  Map<String, dynamic> toJson();

  Future<void> clearFilter();

  /// return a list of filters with his respective callback to remove the filter
  Map<Widget, Function()> get filters;
}
