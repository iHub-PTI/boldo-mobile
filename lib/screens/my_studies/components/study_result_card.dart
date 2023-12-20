import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:boldo/screens/my_studies/estudy_screen.dart';
import 'package:boldo/widgets/card_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StudyResultCard extends StatelessWidget {

  final DiagnosticReport diagnosticReport;

  StudyResultCard({
    super.key,
    required this.diagnosticReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Study(
                        id: diagnosticReport.id ?? '0',
                      )));
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                "Estudio adjuntado",
                                style:
                                regularText.copyWith(
                                  color: ConstantsV2.darkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        "${DateFormat('dd/MM/yy').format(DateTime.parse(diagnosticReport.effectiveDate!).toLocal())}",
                        style: regularText.copyWith(
                          color: ConstantsV2.inactiveText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: ClipRect(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 27,
                                  child: SvgPicture.asset(
                                    diagnosticReport.type == "LABORATORY"
                                        ? 'assets/icon/lab.svg'
                                        : diagnosticReport.type == "IMAGE"
                                        ? 'assets/icon/image.svg'
                                        : diagnosticReport.type == "OTHER"
                                        ? 'assets/icon/other.svg'
                                        : 'assets/images/LogoIcon.svg',
                                    color: ConstantsV2.inactiveText,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${diagnosticReport.type == "LABORATORY" ? 'lab.' : diagnosticReport.type == "IMAGE" ? 'img.' : diagnosticReport.type == "OTHER" ? 'otros' : 'desconocido'}",
                                  style: boldoCorpMediumBlackTextStyle.copyWith(
                                      color: ConstantsV2.activeText),
                                ),
                              ],
                            )),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                      decoration: ShapeDecoration(
                                        color: Constants.secondaryColor100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icon/cloud.svg',
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: diagnosticReport.sourceID ==
                                                (prefs.getString('userId') ?? '')
                                                ?
                                            Text(
                                              "subido por usted",
                                              style:
                                              boldoCorpSmallTextStyle.copyWith(
                                                  color: ConstantsV2.darkBlue),
                                            ):Text(
                                              diagnosticReport.source != null
                                                  ? "subido por ${diagnosticReport.sourceType == 'Practitioner'? 'Dr/a.': '' } "
                                                  "${diagnosticReport.source?.split(' ')[0]}"
                                                  : 'Boldo',
                                              style:
                                              boldoCorpSmallTextStyle.copyWith(
                                                  color: ConstantsV2.darkBlue),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                "${diagnosticReport.description}",
                                style: GoogleFonts.montserrat().copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: ConstantsV2.activeText
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icon/attach-file.svg',
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          "${diagnosticReport.attachmentNumber} ${diagnosticReport.attachmentNumber == "1" ? "archivo adjunto" : "archivos adjuntos"}",
                                          style: boldoCorpSmallTextStyle.copyWith(
                                              color: ConstantsV2.darkBlue),
                                        )
                                      ],
                                    ),
                                  ]
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                diagnosticReport.serviceRequestId != null
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CardButton(
                      function: (){
                        BlocProvider.of<MyStudiesBloc>(context)
                            .add(GetServiceRequests(serviceRequestId: diagnosticReport
                            .serviceRequestId!));
                      },
                      child: Container(
                        child: Text(
                          "Ver orden",
                          style: bigButton,
                        ),
                      ),
                    ),
                  ],
                )
                    : Container()
              ],
            )
        ),
      ),
    );
  }


}