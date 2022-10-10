import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';

class ItemMenu extends StatelessWidget {
  final String image;
  final String title;
  final Function()? action;

  const ItemMenu({
    Key? key,
    required this.image,
    required this.title,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      constraints: const BoxConstraints(minWidth: 136, minHeight: 40),
      padding: const EdgeInsets.all(8),
      child: TextButton.icon(
        onPressed: action,
        icon: SvgPicture.asset(
          image,
          color: ConstantsV2.lightest,
        ),
        label: Text(
          title,
          style: boldoSubTextStyle.copyWith(
            color: ConstantsV2.lightest,
          ),
        ),
      ),
    );
  }
}
