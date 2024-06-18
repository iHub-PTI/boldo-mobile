import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:flutter/material.dart';

class AvailabilityHourWidget extends StatelessWidget {
  AvailabilityHourWidget({
    required this.organizations,
    super.key,
  });

  final List<OrganizationWithAvailability>? organizations;

  @override
  Widget build(BuildContext context) {
    final firstOrganizationName = (organizations?.isNotEmpty ?? true)
        ? organizations?.first.organization?.name ?? 'Desconocido'
        : 'Sin org';
    String _countOfMoreOrganizations =
        "${(organizations?.length ?? 0) > 1 ? ' +${(organizations?.length ?? 0) - 1}' : ''}";

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   child: Text(
                //     availableText(organization?.nextAvailability),
                //     style: boldoBodySRegularTextStyle
                //         .copyWith(
                //       color: ConstantsV2
                //           .grayLight,
                //     ),
                //   ),
                // ),
                Container(
                  child: Text(
                    "$firstOrganizationName$_countOfMoreOrganizations",
                    style: boldoBodySRegularTextStyle.copyWith(
                      color: ConstantsV2.grayLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // if( organization?.nextAvailability?.availability != null ) Card(
          //   elevation: 0.0,
          //   color: ConstantsV2.grayLightAndClear,
          //   shape: RoundedRectangleBorder(
          //     side: BorderSide(color: ConstantsV2.grayLightAndClear, width: 1),
          //     borderRadius: BorderRadius.circular(100),
          //   ),
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          //     child: Row(
          //       children: [
          //         Text("${DateFormat('HH:mm').format(DateTime.parse(organization?.nextAvailability?.availability?? DateTime.now().toString()).toLocal())}",
          //           style: boldoBodySBlackTextStyle.copyWith(color: ConstantsV2.secondaryRegular),),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
