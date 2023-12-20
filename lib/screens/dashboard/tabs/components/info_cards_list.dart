import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoCardList extends StatelessWidget{

  final List<InfoCard> infoCards = [
    InfoCard(
      child: Row(
        children: [
          SvgPicture.asset(
            OrganizationType.pharmacy.svgPath,
            color: OrganizationType.pharmacy.iconColor,
          ),
          const SizedBox(width: 13.5),
          Text(
            OrganizationType.pharmacy.infoCardTitle,
            style: GoogleFonts.workSans().copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontStyle: FontStyle.normal,
            ).copyWith(
              color: ConstantsV2.grayDark,
            ),
          ),
        ],
      ),
      onTap: OrganizationType.pharmacy.page != null? (){
        Navigator.push(
          navKey.currentState!.context,
          MaterialPageRoute(
            builder: (context) => OrganizationType.pharmacy.page!,
          ),
        );
      }: null,
    ),
    InfoCard(
      child: Row(
        children: [
          SvgPicture.asset(
            OrganizationType.hospital.svgPath,
            color: OrganizationType.hospital.iconColor,
          ),
          const SizedBox(width: 13.5),
          Text(
            OrganizationType.hospital.infoCardTitle,
            style: GoogleFonts.workSans().copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontStyle: FontStyle.normal,
            ).copyWith(
              color: ConstantsV2.grayDark,
            ),
          ),
        ],
      ),
      onTap: OrganizationType.hospital.page != null? (){
        Navigator.push(
          navKey.currentState!.context,
          MaterialPageRoute(
            builder: (context) => OrganizationType.hospital.page!,
          ),
        );
      }: null,
    ),
  ];

  @override
  Widget build(BuildContext context){

    List<Widget> list = infoCards.asMap().map((key, value) {
      Widget valueFinal;
      if(key != infoCards.length-1){
         valueFinal = Container(
          padding: const EdgeInsets.only(right: 10),
          child: value,
        );
      }else{
        valueFinal = value;
      }

      MapEntry<int, Widget> result = MapEntry(key, valueFinal);

      return result;
    }).values.toList();


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list,
          ),
        ),
      ),
    );
  }

}