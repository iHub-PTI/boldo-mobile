import 'package:boldo/constants.dart';
import 'package:boldo/models/PositionEntity.dart';
import 'package:flutter/material.dart';

class PinMap extends StatelessWidget {

  final String title;
  final String? subtitle;
  final PositionEntity position;

  PinMap({
    super.key, 
    required this.position,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.55, vertical: 2.77),
          decoration: ShapeDecoration(
            color: const Color(0xFFF7F7F7),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1.39, color: ConstantsV2.secondaryRegular),
              borderRadius: BorderRadius.circular(5.55),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(
                        color: Color(0xFF424549),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                    if(subtitle != null)
                    TextSpan(
                      text: '\n$subtitle',
                      style: const TextStyle(
                        color: Color(0xFF424549),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5.55,
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              shadowPin,
            ]
          ),
          child: const Icon(
            Icons.place_rounded,
            color: ConstantsV2.secondaryRegular,
          ),
        ),
      ],
    );
  }

}