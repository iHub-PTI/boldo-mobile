import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:boldo/screens/booking/booking_confirm_screen.dart';
import 'package:boldo/screens/details/appointment_details.dart';
import 'package:boldo/screens/details/prescription_details.dart';
import 'package:boldo/screens/family/tabs/my_managers_tab.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:provider/provider.dart';

class FamilyRectangleCard extends StatefulWidget {
  final Patient? patient;
  final bool isDependent;
  const FamilyRectangleCard({
    Key? key,
    this.patient,
    required this.isDependent,
  }) : super(key: key);

  @override
  State<FamilyRectangleCard> createState() => _FamilyRectangleCardState();
}

class _FamilyRectangleCardState extends State<FamilyRectangleCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyManagersTab()
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 8),
              child: const ProfileImageView(height: 60, width: 60, border: false),
            ),
            Container(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Selector<UserProvider, String>(
                    builder: (_, name, __){
                      return Text(
                        name,
                        style: boldoSubTextMediumStyle.copyWith(
                          color: ConstantsV2.activeText
                        ),
                      );
                    },
                    selector: (buildContext, userProvider) =>
                    "${userProvider.getGivenName} ${userProvider.getFamilyName}",
                  ),
                  Text(
                    ! widget.isDependent ? "mi perfil" : "Familar",
                    style: boldoCorpMediumTextStyle.copyWith(
                      color: ConstantsV2.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteFamilyWidget extends StatelessWidget {
  final void Function(String result)? onTapCallback;
  const DeleteFamilyWidget({
    Key? key,
    required this.onTapCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        if (onTapCallback != null) {
          onTapCallback!(result.toString());
        }
      },
      child: const Icon(
        Icons.more_vert,
        color: Colors.grey,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Descartar',
          child: Container(
            height: 45,
            decoration: const BoxDecoration(color: Constants.accordionbg),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SvgPicture.asset('assets/icon/trash.svg'),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 2.0),
                  child: Text('Cancelar cita'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
