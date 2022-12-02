import 'package:boldo/blocs/family_bloc/dependent_family_bloc.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/screens/family/tabs/my_managers_tab.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:boldo/constants.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';

class CaretakerRectangleCard extends StatefulWidget {
  final Patient? patient;
  final bool isDependent;
  const CaretakerRectangleCard({
    Key? key,
    this.patient,
    required this.isDependent,
  }) : super(key: key);

  @override
  State<CaretakerRectangleCard> createState() => _CaretakerRectangleCardState();
}

class _CaretakerRectangleCardState extends State<CaretakerRectangleCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: InkWell(
          onTap: widget.isDependent ? (){} : (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyManagersTab()
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width-16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 8),
                  child: widget.isDependent
                      ? ProfileImageView2(height: 60, width: 60, border: false, patient: widget.patient,)
                      : const ProfileImageViewTypeForm(height: 60, width: 60, border: false, form: "rounded",),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.isDependent
                                ? Text(
                              "${widget.patient!.givenName} ${widget.patient!.familyName}",
                              style: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.activeText
                              ),
                            )
                                :Text(
                              "${prefs.getString('name')?.split(' ')[0] ?? ''}${prefs.getString('lastName')?.split(' ')[0] ?? ''}",
                              style: boldoSubTextMediumStyle.copyWith(
                                  color: ConstantsV2.activeText
                              ),
                            ),
                            widget.isDependent && !(prefs.getBool(isFamily)?? false) ? UnlinkCaretakerWidget(
                              onTapCallback: (result) async {
                                if (result == 'Desvincular') {
                                  BlocProvider.of<FamilyBloc>(context).add(UnlinkCaretaker(id: widget.patient!.id!));
                                }
                              },
                            ): Container(),
                          ],
                        ),
                      ),
                      Text(
                        ! widget.isDependent ? "mi perfil" : widget.patient!.relationshipDisplaySpan??'',
                        style: boldoCorpMediumTextStyle.copyWith(
                          color: ConstantsV2.green,
                        ),
                      ),
                      if(widget.isDependent)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right:8.0),
                              child: Text("agregado el ${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.patient!.startDependenceDate!))}",
                                style: boldoCorpSmallTextStyle.copyWith(
                                  color: ConstantsV2.inactiveText,
                                ),
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UnlinkCaretakerWidget extends StatelessWidget {
  final void Function(String result)? onTapCallback;
  const UnlinkCaretakerWidget({
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
      child: Padding(
        padding: const EdgeInsets.only(right:8.0, top: 8.0),
        child: SvgPicture.asset('assets/icon/familyTrash.svg'),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Desvincular',
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
                  child: Text('Desvincular Gestor'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
