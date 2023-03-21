import 'package:boldo/constants.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';



class DiagnosticReportCard extends StatefulWidget {
  final DiagnosticReport diagnosticReport;
  const DiagnosticReportCard({
    Key? key,
    required this.diagnosticReport,
  }) : super(key: key);

  @override
  State<DiagnosticReportCard> createState() => _DiagnosticReportCardState();
}

class _DiagnosticReportCardState extends State<DiagnosticReportCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 4),
          child: InkWell(
            onTap: () {

            },
            child: Container(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Estudio reciente",
                        style: boldoCorpSmallTextStyle.copyWith(
                            color: ConstantsV2.darkBlue
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Text("${DateFormat('dd/MM/yy').format(DateTime.parse(widget.diagnosticReport.effectiveDate!).toLocal())}",
                          style: boldoCorpSmallTextStyle.copyWith(
                              color: ConstantsV2.darkBlue
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: ClipOval(
                          child: SizedBox(
                            width: 54,
                            height: 54,
                            child:SvgPicture.asset(
                              widget.diagnosticReport.type == "LABORATORY"
                                  ? 'assets/icon/lab.svg'
                                  : widget.diagnosticReport.type == "IMAGE"
                                  ? 'assets/icon/image.svg'
                                  : widget.diagnosticReport.type == "OTHER"
                                  ? 'assets/icon/other.svg'
                                  : 'assets/images/LogoIcon.svg',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // For a future Laboratory's Name
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text("${widget.diagnosticReport.description}",
                            style: boldoCorpMediumTextStyle.copyWith(
                                color: ConstantsV2.inactiveText
                            ),
                          ),
                          Text("Subido por ${widget.diagnosticReport.source}",
                            style: boldoCorpMediumTextStyle.copyWith(
                                color: ConstantsV2.inactiveText
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icon/attach-file.svg',
                                ),
                                Text("${widget.diagnosticReport.attachmentNumber} ${widget.diagnosticReport.attachmentNumber== "1" ? "archivo adjunto": "archivos adjuntos"}",
                                  style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.darkBlue),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /*
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                // TODO redirect to medical study page
                              },
                              child: Card(
                                  margin: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
                                  ),
                                  color: ConstantsV2.orange.withOpacity(0.10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                                    child: Text("ver archivo"),
                                  )
                              ),
                            ),
                          ),*/ const SizedBox(height: 14,),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

}
