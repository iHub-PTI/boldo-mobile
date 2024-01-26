import 'package:boldo/constants.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:flutter/material.dart';

class OrganizationPhoto extends StatelessWidget {

  final Organization organization;

  const OrganizationPhoto({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    Widget? child;

    int countOfWords = organization.name?.split(" ").length?? 0;

    String? text = organization.name?.split(" ").sublist(0, countOfWords < 2? countOfWords : 2).map((e) => e[0]).join();

    child = ImageViewTypeForm(
      height: 30,
      width: 30,
      border: false,
      url: organization.logoUrl,
      elevation: 0,
      text: text,
      backgroundColor: ConstantsV2.green,
      textStyle: const TextStyle(
        color: Color(0xFFF5F5F5),
        fontSize: 13,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
        height: 0,
      ),
    );

    return Container(
      child: child,
    );
  }

}