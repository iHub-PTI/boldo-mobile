import 'package:boldo/blocs/download_studies_orders_bloc/download_studies_orders_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/screens/studies_orders/attach_study_by_order.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/card_button.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class ServiceRequestCard extends StatefulWidget {

  final ServiceRequest serviceRequest;

  ServiceRequestCard({
    Key? key,
    required this.serviceRequest,
  }) : super(key: key);

  @override
  State<ServiceRequestCard> createState() => ServiceRequestCardState();

}

class ServiceRequestCardState extends State<ServiceRequestCard> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context){

    return BlocProvider<DownloadStudiesOrdersBloc>(
      create: (BuildContext context) => DownloadStudiesOrdersBloc(),
      child: Column(
        children: [
          Container(
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
                                "Nro de orden: ${widget.serviceRequest.orderNumber}",
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
                      if(widget.serviceRequest.authoredDate != null)
                        Text(
                          "${DateFormat('dd/MM/yy').format(DateTime.parse(widget.serviceRequest.authoredDate!).toLocal())}",
                          style: regularText.copyWith(
                            color: ConstantsV2.inactiveText,
                          ),
                        )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 2, right: 1,),
                        child: ClipRect(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 27,
                                width: 27,
                                child: SvgPicture.asset(
                                  widget.serviceRequest.category ==
                                      "Laboratory"
                                      ? 'assets/icon/lab.svg'
                                      : widget.serviceRequest.category ==
                                      "Diagnostic Imaging"
                                      ? 'assets/icon/image.svg'
                                      : widget.serviceRequest.category ==
                                      "Other"
                                      ? 'assets/icon/other.svg'
                                      : 'assets/images/LogoIcon.svg',
                                  color: ConstantsV2.inactiveText,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "${widget.serviceRequest.category == "Laboratory" ? 'lab.' : widget.serviceRequest.category == "Diagnostic Imaging" ? 'img.' : widget.serviceRequest.category == "Other" ? 'other.' : 'Desconocido'}",
                                style: boldoCorpMediumBlackTextStyle.copyWith(
                                  color: ConstantsV2.activeText,
                                ),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "${widget.serviceRequest.description?? "Sin descripción"}",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat().copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: ConstantsV2.activeText,
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
                              gender: widget.serviceRequest.doctor?.gender,
                              url: widget.serviceRequest.doctor?.photoUrl,
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
                                  widget.serviceRequest.doctor!.gender == 'female'
                                      ? 'Dra. ${toLowerCase(widget.serviceRequest.doctor!.givenName!).trim().split(RegExp(' +'))[0]} ${toLowerCase(widget.serviceRequest.doctor!.familyName!).trim().split(RegExp(' +'))[0]}'
                                      : 'Dr. ${toLowerCase(widget.serviceRequest.doctor!.givenName!).trim().split(RegExp(' +'))[0]} ${toLowerCase(widget.serviceRequest.doctor!.familyName!).trim().split(RegExp(' +'))[0]}',
                                  style: GoogleFonts.montserrat().copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: ConstantsV2.activeText
                                  ),
                                ),
                              ),
                              if(widget.serviceRequest.urgent?? false)
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
          Container(
            padding: const EdgeInsets.only(left: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                actions(context: context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget actions({required BuildContext context}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BlocBuilder<DownloadStudiesOrdersBloc, DownloadStudiesOrdersState>(
          builder: (BuildContext context, state){
            if(state is Loading){
              return loadingStatus();
            }else{
              return CardButton(
                function: (){
                  BlocProvider.of<DownloadStudiesOrdersBloc>(context).add(
                    DownloadStudiesOrders(
                      listOfIds: [widget.serviceRequest.id],
                      context: context,
                    ),
                  );
                },
                decoration: null,
                child: Container(
                  child: Container(
                    child: Text(
                      "Descargar",
                      style: bigButton,
                    ),
                  ),
                ),
              );
            }
          },
        ),
        CardButton(
          function: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AttachStudyByOrderScreen(
                    studyOrder: widget.serviceRequest,
                    doctor: widget.serviceRequest.doctor,
                  )
              )
            );
          },
          child: Container(
            child: Container(
              child: Text(
                "Adjuntar archivo",
                style: bigButton,
              ),
            ),
          ),
        ),
      ],
    );
  }

}