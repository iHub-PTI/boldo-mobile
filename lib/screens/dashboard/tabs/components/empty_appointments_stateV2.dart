import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:boldo/provider/utils_provider.dart';

import '../../../../constants.dart';
import 'package:boldo/constants.dart';
import 'package:flutter/foundation.dart';

class EmptyAppointmentsStateV2 extends StatelessWidget {
  final String picture;
  const EmptyAppointmentsStateV2(
      {Key? key, required this.picture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        child: Column(
          children: [
            const Text(
              "nada para mostrar",
            ),
            Container(
              padding: EdgeInsets.only(left: 1, right: 1),
              child: SvgPicture.asset(
                'assets/icon/${picture}',
                color: Color(0xff233C58),
                fit: BoxFit.cover,
              ),
            ),
            const Text(
              "a medida que uses la app, las novedades se van a ir mostrando en esta sección",
            ),
          ]
        )
      )
    );
  }
}
