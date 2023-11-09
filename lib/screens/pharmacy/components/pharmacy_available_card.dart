import 'package:boldo/constants.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/MapLauncher.dart';
import 'package:flutter/material.dart';

class PharmacyAvailableCard extends StatelessWidget {

  final Organization organization;

  PharmacyAvailableCard({
    Key? key,
    required this.organization,
  }): super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: ShapeDecoration(
        color: ConstantsV2.lightAndClear,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 2,
            color: ConstantsV2.grayLightAndClear,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            child: Center(
              child: organizationProfilePicture(organization: organization),
            ),
          ),
          const SizedBox(
            width: 3,
          ),
          Expanded(
            child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                organizationDescription(organization: organization),
                const SizedBox(
                  height: 4,
                ),
                organizationDirection(organization: organization),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget organizationDescription({required Organization organization}){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            organization.name?? "Sin nombre",
            style: bodyLargeBlack.copyWith(
              color: ConstantsV2.blueDark,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contacto: ",
                style: bodySmallRegular.copyWith(
                  color: ConstantsV2.activeText,
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                organization.contactList?.firstWhere((element) => element.type == 'phone', orElse: ()=> organization.contactList!.first).value?? "sin contacto",
                style: bodySmallRegular.copyWith(
                  color: ConstantsV2.activeText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget organizationDirection({required Organization organization}){
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   "Av. Gral Santos 1254 casi Las Marias",
                //   style: TextStyle(
                //     color: ConstantsV2.darkBlue,
                //     fontSize: 9,
                //     fontFamily: 'Montserrat',
                //     fontWeight: FontWeight.w500,
                //     height: 0,
                //   ),
                // ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: ()=> MapsLauncher.launchQuery(organization.name?? 'Paraguay'),
              child: Container(
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: ConstantsV2.primaryRegular,
                      size: 9,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      "ver en el mapa",
                      style: TextStyle(
                        color: ConstantsV2.primaryRegular,
                        fontSize: 9,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget organizationProfilePicture({required Organization organization}){

    Widget? child;

    String? text = organization.name?.split(" ").sublist(0, 2).map((e) => e[0]).join();

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