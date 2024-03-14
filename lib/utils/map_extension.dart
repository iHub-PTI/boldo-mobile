import 'dart:core';

extension MapExtension on Map {

  Map<String, String> toLowercaseKeys(){

    Map<String, String> newMap = {};

    keys.toList().forEach((key) {

      newMap.addAll({
        key.toLowerCase():
        this[key]!
      });
    });

    return newMap;
  }

}