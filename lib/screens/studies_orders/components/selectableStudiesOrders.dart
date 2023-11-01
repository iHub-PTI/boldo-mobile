import 'package:boldo/constants.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/studies_orders/components/studyOrderCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectableServiceRequest extends StatefulWidget {

  final List<ServiceRequest> servicesRequests;

  SelectableServiceRequest({
    Key? key,
    required this.servicesRequests,
  }) : super(key: key);

  @override
  State<SelectableServiceRequest> createState() => SelectableServiceRequestState();

}


class SelectableServiceRequestState extends State<SelectableServiceRequest> with TickerProviderStateMixin {

  bool selectAll = false;
  Map<ServiceRequest, bool> listSelectableElements = {};
  late AnimationController _controller;

  Duration durationEffect = const Duration(milliseconds: 300);

  @override
  void initState(){
    _controller = AnimationController(
      vsync: this,
      duration: durationEffect,
    );
    widget.servicesRequests.forEach((e) => listSelectableElements[e]= false);
    super.initState();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        tabDownload(),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.separated(
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) => const Divider(
            color: Colors.transparent,
            height: 10,
          ),
          itemCount: listSelectableElements.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index){
            ServiceRequest serviceRequest = listSelectableElements.keys.elementAt(index);
            bool? value = listSelectableElements[serviceRequest];
            return ServiceRequestCard(
              serviceRequest: serviceRequest,
              selected: value?? false,
              selectedFunction: (){
                listSelectableElements[serviceRequest] = true;
                checkHeader();

              },
              unselectedFunction: (){
                listSelectableElements[serviceRequest] = false;
                checkHeader();
              },
            );
          },
        ),
        ),
      ],
    );
  }

  void checkHeader(){
    if(listSelectableElements.containsValue(true)){
      _controller.forward().then((value) => setState(() {

      }));
    }else{
      _controller.reverse().then((value) => setState(() {

      }));
    }
  }

  Widget tabDownload(){
    return AnimatedSize(
      duration: durationEffect,
      child: Container(
        height: _controller.isCompleted? null : 0,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.53),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 5,),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (){
                            selectAll =false;
                            listSelectableElements.updateAll((key, value) => value = selectAll);
                            checkHeader();
                          },
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: ConstantsV2.primaryRegular,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15,),
                      AnimatedSwitcher(
                        duration: durationEffect,
                        child: Text(
                          key: Key("${listSelectableElements.values.where((element) => element==true).length}"),
                          "${listSelectableElements.values.where((element) => element==true).length}",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            color: ConstantsV2.blueDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: (){
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(
                              Icons.save_alt_rounded,
                              color: ConstantsV2.grayDark,
                            ),
                            const SizedBox(width: 8,),
                            Text(
                              "Descargar",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: selectAll,
                      activeColor: ConstantsV2.orange,
                      checkColor: Colors.white,
                      onChanged: (value) {
                        selectAll = !selectAll;
                        listSelectableElements.updateAll((key, value) => value = selectAll);
                        checkHeader();
                      },
                    ),
                    const Flexible(
                      child: Text(
                        chooseAll,
                        style: TextStyle(color: ConstantsV2.activeText),
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

}