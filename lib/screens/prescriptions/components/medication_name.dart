import 'package:boldo/constants.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MedicationName extends StatelessWidget{

  final Prescription prescription;
  final double spacing;

  MedicationName({
    Key? key,
    required this.prescription,
    this.spacing = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture
              .asset(
            'assets/icon/pill.svg',
            color: ConstantsV2.darkBlue,
            width: 15,
          ),
          SizedBox(
            width: spacing,
          ),
          Container(
            child:
            Flexible(
              child: Text(
                "${prescription.medicationName}",
                style: medicationTextStyle,
                overflow:
                TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }



}