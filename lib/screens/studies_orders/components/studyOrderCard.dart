import 'package:boldo/constants.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/screens/studies_orders/attach_study_by_order.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class ServiceRequestCard extends StatelessWidget {

  final ServiceRequest serviceRequest;
  ServiceRequestCard({
    Key? key,
    required this.serviceRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){

    return Container(
      decoration: BoxDecoration(
        color: ConstantsV2.lightest,
        boxShadow: [
          shadowRegular
        ],
      ),
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AttachStudyByOrderScreen(
                      studyOrder: serviceRequest,
                      doctor: serviceRequest.doctor,
                    )
                )
            );
          },
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 6, right: 4),
                            child: ClipRect(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 27,
                                    width: 27,
                                    child: SvgPicture.asset(
                                      serviceRequest.category ==
                                          "Laboratory"
                                          ? 'assets/icon/lab.svg'
                                          : serviceRequest.category ==
                                          "Diagnostic Imaging"
                                          ? 'assets/icon/image.svg'
                                          : serviceRequest.category ==
                                          "Other"
                                          ? 'assets/icon/other.svg'
                                          : 'assets/images/LogoIcon.svg',
                                      color: ConstantsV2.inactiveText,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "${serviceRequest.category == "Laboratory" ? 'lab.' : serviceRequest.category == "Diagnostic Imaging" ? 'img.' : serviceRequest.category == "Other" ? 'other.' : 'Desconocido'}",
                                    style: boldoCorpMediumBlackTextStyle.copyWith(
                                        color: ConstantsV2.activeText),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
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
                                              "Nro de orden: ${serviceRequest.orderNumber}",
                                              style:
                                              CorpPMediumTextStyle.copyWith(
                                                  color: ConstantsV2.darkBlue),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    if(serviceRequest.authoredDate != null)
                                      Text(
                                        "${DateFormat('dd/MM/yy').format(DateTime.parse(serviceRequest.authoredDate!).toLocal())}",
                                        style: boldoCorpSmallTextStyle.copyWith(
                                          color: ConstantsV2.darkBlue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "${serviceRequest.description?? "Sin descripción"}",
                                  style: GoogleFonts.montserrat().copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: ConstantsV2.activeText
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 33,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ImageViewTypeForm(
                                  height: 24.44,
                                  width: 24.44,
                                  border: false,
                                  gender: serviceRequest.doctor?.gender,
                                  url: serviceRequest.doctor?.photoUrl,
                                  elevation: 0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                        serviceRequest.doctor!.gender == 'female'
                                            ? 'Dra. ${toLowerCase(serviceRequest.doctor!.givenName!).trim().split(RegExp(' +'))[0]} ${toLowerCase(serviceRequest.doctor!.familyName!).trim().split(RegExp(' +'))[0]}'
                                            : 'Dr. ${toLowerCase(serviceRequest.doctor!.givenName!).trim().split(RegExp(' +'))[0]} ${toLowerCase(serviceRequest.doctor!.familyName!).trim().split(RegExp(' +'))[0]}',
                                      style: GoogleFonts.montserrat().copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: ConstantsV2.activeText
                                      ),
                                    ),
                                  ),
                                  if(serviceRequest.urgent?? false)
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icon/warning.svg',
                                          width: 18,
                                          height: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                            "urgente",
                                            style: TextStyle(
                                              color: ConstantsV2.orange,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Montserrat',
                                            )
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: ConstantsV2.orange.withOpacity(0.10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(6)),
                      ),
                    ),
                    child: Container(
                      child: Text(
                        "Adjuntar archivo",
                        style: bigButton,
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
      ),
    );
  }

}