import 'package:boldo/models/VaccinationList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/background.dart';

class PassportDetail extends StatefulWidget {
  final UserVaccinate? userVaccinate;
  const PassportDetail({Key? key, this.userVaccinate}) : super(key: key);

  @override
  State<PassportDetail> createState() => _PassportDetailState();
}

// implementation of the PassportDetail state
class _PassportDetailState extends State<PassportDetail> {
  late PageController controller;
  // initial state of the page
  @override
  void initState() {
    controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // the first element of the stack is the background
          const Background(text: "linkFamily")
        ],
      )
    );
  }
}
