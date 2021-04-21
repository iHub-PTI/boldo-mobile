import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class TopBannerPresentation extends StatelessWidget {
  const TopBannerPresentation({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          "assets/Logo_title.svg",
          fit: BoxFit.cover,
          alignment: Alignment.center,
          width: 90,
        ),
        const SizedBox(
          height: 30,
        ),
        const SizedBox(
          width: 300,
          height: 70,
          child: Text(
            "Ecosistema Abierto de Productos Digitales para la Salud",
            style: boldoSubTextStyle,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
