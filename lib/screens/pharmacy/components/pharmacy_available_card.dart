import 'package:boldo/constants.dart';
import 'package:boldo/models/Contact.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/widgets/organization_photo.dart';
import 'package:flutter/material.dart';

class PharmacyAvailableCard extends StatelessWidget {
  final Organization organization;

  PharmacyAvailableCard({
    Key? key,
    required this.organization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(color: ConstantsV2.lightest, boxShadow: [
        shadowRegular,
      ]),
      child: Container(
        padding: const EdgeInsets.only(
          top: 0,
          right: 8,
          bottom: 4,
          left: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    organizationDescription(organization: organization),
                    const SizedBox(
                      height: 4,
                    ),
                    organizationDirection(
                      organization: organization,
                      context: context,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget organizationDescription({required Organization organization}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getFinancerHeader(),
        ],
      ),
    );
  }

  Widget _getFinancerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
        ),
      ),
      child: Row(
        children: [
          Center(
            child: OrganizationPhoto(organization: organization),
          ),
          const SizedBox(
            width: 8,
          ),
          _getFinancerDescription(),
        ],
      ),
    );
  }

  Widget _getFinancerDescription() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            organization.name ?? "Sin nombre",
            style: bodyLargeBlack.copyWith(
              color: ConstantsV2.activeText,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            organization.organizationName ?? "Sin nombre",
            style: regularText.copyWith(
              color: ConstantsV2.activeText,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget organizationDirection({
    required Organization organization,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.only(right: 5, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getAddress(),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getContact(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAddress() {
    return Text(
      organization.address?.addressDescription ??
          "Av. Gral Santos 1254 casi Las Marias",
      style: bodySmallRegular.copyWith(
        color: ConstantsV2.activeText,
      ),
    );
  }

  Widget _getContact() {
    //get phone type
    Contact? _contactDescription = organization.contactList?.firstWhere(
        (element) => element.type == 'phone',
        orElse: () => organization.contactList!.first);

    //get other contact type
    _contactDescription =
        _contactDescription ?? organization.contactList?.first;

    return Row(
      children: [
        if (_contactDescription != null)
          _contactDescription.typeIcon(
            color: ConstantsV2.orange,
          ),
        if (_contactDescription != null)
          const SizedBox(
            width: 5,
          ),
        Text(
          _contactDescription?.value ?? "sin contacto",
          style: bodySmallRegular.copyWith(
            color: ConstantsV2.activeText,
          ),
        ),
      ],
    );
  }
}
