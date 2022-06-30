import 'package:flutter/material.dart';

class MyStudies extends StatefulWidget {
  MyStudies({Key? key}) : super(key: key);

  @override
  State<MyStudies> createState() => _MyStudiesState();
}

class _MyStudiesState extends State<MyStudies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mis estudios"),),
      body: Column(children: [
        Text('Estudios'),
        Text('Subí y consultá resultados de estudios provenientes de varias fuentes.'),
      ],),
    );
  }
}