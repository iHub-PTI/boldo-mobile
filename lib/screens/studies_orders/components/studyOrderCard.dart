import 'package:boldo/blocs/download_studies_orders_bloc/download_studies_orders_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/screens/studies_orders/attach_study_by_order.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class ServiceRequestCard extends StatefulWidget {

  final ServiceRequest serviceRequest;
  final Function? selectedFunction;
  final Function? unselectedFunction;
  final bool selected;
  final Duration durationEffect;

  ServiceRequestCard({
    Key? key,
    required this.serviceRequest,
    this.selectedFunction,
    this.unselectedFunction,
    this.selected = false,
    this.durationEffect = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<ServiceRequestCard> createState() => ServiceRequestCardState();

}

class ServiceRequestCardState extends State<ServiceRequestCard> with TickerProviderStateMixin {

  bool selected = false;

  late DecorationTween decorationTween ;

  late AnimationController _controller;

  @override
  void didUpdateWidget(ServiceRequestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.selected != widget.selected){
      selected = widget.selected;
      if(selected){
        _controller.forward();
      }else{
        _controller.reverse();
      }
      setState(() {

      });
    }
  }

  @override
  void initState(){
    selected = widget.selected;
    decorationTween = DecorationTween(
      begin: selected? selectedCardDecoration: BoxDecoration(
        color: ConstantsV2.lightest,
        boxShadow: [
          shadowRegular
        ],
      ),
      end: selected? BoxDecoration(
        color: ConstantsV2.lightest,
        boxShadow: [
          shadowRegular
        ],
      ) : selectedCardDecoration,
    );
    _controller = AnimationController(
      vsync: this,
      duration: widget.durationEffect,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context){

    return BlocProvider<DownloadStudiesOrdersBloc>(
      create: (BuildContext context) => DownloadStudiesOrdersBloc(),
      child: Container(
        child: DecoratedBoxTransition(
          decoration: decorationTween.animate(_controller),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                onLongPress: (){
                  if(selected == false) {
                    widget.selectedFunction?.call();
                    selected = true;
                    _controller.forward();
                  }else{
                    widget.unselectedFunction?.call();
                    selected = false;
                    _controller.reverse();
                  }
                  setState(() {

                  });
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
                                                    "Nro de orden: ${widget.serviceRequest.orderNumber}",
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
                                          if(widget.serviceRequest.authoredDate != null)
                                            Text(
                                              "${DateFormat('dd/MM/yy').format(DateTime.parse(widget.serviceRequest.authoredDate!).toLocal())}",
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
                                        "${widget.serviceRequest.description?? "Sin descripción"}",
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          unselectButton(context: context),
                          actions(context: context),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }

  Widget unselectButton({required BuildContext context}){
    return AnimatedOpacity(
      duration: widget.durationEffect,
      opacity: selected? 1 : 0,
      child: Visibility(
        visible: selected,
        child: Container(
          padding: const EdgeInsets.all(2),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFEB8B76),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            shadows: [
              const BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 4,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          child: const Icon(Icons.check, size: 20,color: ConstantsV2.lightGrey,),
        ),
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
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<DownloadStudiesOrdersBloc>(context).add(
                      DownloadStudiesOrders(
                        listOfIds: [widget.serviceRequest.id],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    child: Container(
                      child: Text(
                        "Descargar",
                        style: bigButton,
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
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
          ),
        ),
      ],
    );
  }

}