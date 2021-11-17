import 'package:flutter/foundation.dart';

class Soep {
  final String title;
  final String date;
  final String description;

  Soep({
    @required this.title,
    @required this.date,
    @required this.description,
  });
}

final String fakeDescr =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sociis tristique ut odio lorem ultrices adipiscing lacus tortor, et. Dictumst eu iaculis commodo platea.";
List<Soep> soepFakeDate = [
  Soep(title: 'Primera Consulta', date: '25/12/2020', description: fakeDescr),
  Soep(title: 'Seguimiento', date: '30/01/2021', description: fakeDescr),
  Soep(title: 'Seguimiento', date: '05/03/2021', description: fakeDescr),
  Soep(title: 'Seguimiento', date: '09/04/2021', description: fakeDescr),
];
