import 'package:boldo/blocs/studies_orders_bloc/studiesOrders_bloc.dart' as studies_orders_bloc;
import 'package:boldo/main.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:boldo/screens/studies_orders/attach_study_by_order.dart';
import 'package:boldo/screens/studies_orders/components/selectableStudiesOrders.dart';
import 'package:boldo/screens/studies_orders/components/studyOrderCard.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/header_page.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/DiagnosticReport.dart';
import 'estudy_screen.dart';
import 'new_study.dart';

class MyStudies extends StatefulWidget {
  MyStudies({Key? key}) : super(key: key);

  @override
  State<MyStudies> createState() => _MyStudiesState();
}

class _MyStudiesState extends State<MyStudies> with SingleTickerProviderStateMixin {
  List<DiagnosticReport> diagnosticReport = [];
  ServiceRequest? serviceRequest;

  late TabController _tabStudiesController;

  @override
  void initState() {

    _tabStudiesController = TabController(
      length: 2,
      vsync: this,
    );

    BlocProvider.of<MyStudiesBloc>(context).add(GetPatientStudiesFromServer());
    super.initState();
  }

  @override
  void dispose(){
    _tabStudiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [],
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: BlocProvider(
            create: (BuildContext context) =>
            studies_orders_bloc.StudiesOrdersBloc()
              ..add(studies_orders_bloc.GetStudiesOrders()),
            child: BlocListener<MyStudiesBloc, MyStudiesState>(
              listener: (context, state) {
                if (state is DiagnosticLoaded) {
                  setState(() {
                    diagnosticReport = state.studiesList;

                    diagnosticReport.sort(((a, b) {
                      if (a.effectiveDate == null || b.effectiveDate == null) {
                        return 0;
                      }

                      try {
                        DateTime dateA =
                        DateTime.parse(a.effectiveDate as String);
                        DateTime dateB =
                        DateTime.parse(b.effectiveDate as String);

                        return dateB.compareTo(dateA);
                      } on FormatException catch (e) {
                        print(e.toString());
                        return 0;
                      }
                    }));
                  });
                }

                if (state is Failed) {
                  print('algo falló: ${state.msg}');
                  setState(() {});
                  emitSnackBar(
                      context: context,
                      text: 'Falló la obtención de estudios',
                      status: ActionStatus.Fail
                  );
                }

                if (state is ServiceRequestLoaded) {
                  serviceRequest = state.serviceRequest;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AttachStudyByOrderScreen(
                                studyOrder: serviceRequest == null ? ServiceRequest() : serviceRequest!,
                                doctor: serviceRequest?.doctor,
                              )));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            BackButtonLabel(),
                            Expanded(
                              child: header("Mis Estudios", "Estudios"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Administrá tus estudios médicos: Subí, consultá y accedé a tu historial de órdenes y resultados',
                      style: boldoHeadingTextStyle.copyWith(fontSize: 12),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(child: body()),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          if(BlocProvider.of<MyStudiesBloc>(context).state is Loading){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Favor aguardar durante la carga."),
                backgroundColor: Colors.redAccent,
              ),
            );
          }else{
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => NewStudy()
                )
            );
          }
        },
        child: BlocBuilder<MyStudiesBloc, MyStudiesState>(
          builder: (BuildContext context, state) {
            if(state is Loading){
              return const CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                backgroundColor: Constants.primaryColor600,
              );
            }else{
              return Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'nuevo estudio',
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SvgPicture.asset(
                        'assets/icon/upload.svg',
                      ),
                    ],
                  )
              );
            }
          },
        ),
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        tab(),
        Expanded(
          child: _tabs(),
        ),
      ],
    );
  }

  Widget tab(){
    return Container(
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Center(
              child: SvgPicture.asset(
                'assets/decorations/line_separator.svg',
              )
          ),
          TabBar(
            labelStyle: boldoTabHeaderSelectedTextStyle,
            unselectedLabelStyle: boldoTabHeaderUnselectedTextStyle,
            indicatorColor: Colors.transparent,
            unselectedLabelColor:
            const Color.fromRGBO(119, 119, 119, 1),
            labelColor: ConstantsV2.activeText,
            controller: _tabStudiesController,
            tabs: [
              const Text(
                'Órdenes',
              ),
              const Text(
                'Resultados',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabs(){
    return TabBarView(
      physics: const ClampingScrollPhysics(),
      controller: _tabStudiesController,
      children: [
        studiesOrders(),
        studyResults(),
      ],
    );
  }

  Widget studyResults(){
    return BlocBuilder<MyStudiesBloc, MyStudiesState>(
      builder: (BuildContext context, state) {
        if(state is Loading){
          return loadingStatus();
        }else{
          return ListView.separated(
            physics: const ClampingScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) => const Divider(
              color: Colors.transparent,
              height: 5,
            ),
            itemCount: diagnosticReport.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: showStudy,
          );
        }
      },
    );
  }

  Widget studiesOrders(){
    return BlocBuilder<studies_orders_bloc.StudiesOrdersBloc, studies_orders_bloc.StudiesOrdersState>(
      builder: (BuildContext context, state){
        if(state is studies_orders_bloc.StudiesOrdersLoaded){
          return state.studiesOrders.isNotEmpty ? SelectableServiceRequest(
            servicesRequests: state.studiesOrders,
          ) : const Expanded(
        child: EmptyStateV2(
          picture: "empty_studies.svg",
          titleBottom: "Aún no tenés estudios",
          textBottom:
          "A medida en que uses la aplicación podrás ir viendo tus estudios",
        ));
        } else if(state is studies_orders_bloc.LoadingOrders) {
          return loadingStatus();
        } else {
          return Container();
        }
      });
  }

  Widget showStudy(BuildContext context, int index) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Study(
                        id: diagnosticReport[index].id ?? '0',
                      )));
        },
        child: Column(
          children: [
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
                                diagnosticReport[index].type == "LABORATORY"
                                    ? 'assets/icon/lab.svg'
                                    : diagnosticReport[index].type == "IMAGE"
                                    ? 'assets/icon/image.svg'
                                    : diagnosticReport[index].type == "OTHER"
                                    ? 'assets/icon/other.svg'
                                    : 'assets/images/LogoIcon.svg',
                                color: ConstantsV2.inactiveText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "${diagnosticReport[index].type == "LABORATORY" ? 'lab.' : diagnosticReport[index].type == "IMAGE" ? 'img.' : diagnosticReport[index].type == "OTHER" ? 'otros' : 'desconocido'}",
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
                                        child: diagnosticReport[index].sourceID ==
                                            (prefs.getString('userId') ?? '')
                                            ?
                                        Text(
                                          "subido por usted",
                                          style:
                                          boldoCorpSmallTextStyle.copyWith(
                                              color: ConstantsV2.darkBlue),
                                        ):Text(
                                          diagnosticReport[index].source != null
                                              ? "subido por ${diagnosticReport[index].sourceType == 'Practitioner'? 'Dr/a.': '' } "
                                              "${diagnosticReport[index].source?.split(' ')[0]}"
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
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "${DateFormat('dd/MM/yy').format(DateTime.parse(diagnosticReport[index].effectiveDate!).toLocal())}",
                                style: boldoCorpSmallTextStyle.copyWith(
                                  color: ConstantsV2.darkBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),

                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "${diagnosticReport[index].description}",
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
                                      "${diagnosticReport[index].attachmentNumber} ${diagnosticReport[index].attachmentNumber == "1" ? "archivo adjunto" : "archivos adjuntos"}",
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
            diagnosticReport[index].serviceRequestId != null
                ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: GestureDetector(
                    onTap: (){
                      BlocProvider.of<MyStudiesBloc>(context)
                          .add(GetServiceRequests(serviceRequestId: diagnosticReport[index]
                          .serviceRequestId!));
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
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                          child: Text(
                            "Ver orden",
                            style: bigButton,
                          ),
                        )),
                  ),
                ),
              ],
            )
                : Container()
          ],
        )
      ),
    );
  }

  Widget showStudyOrder({required ServiceRequest serviceRequest}) {
    return ServiceRequestCard(
      serviceRequest: serviceRequest,
    );
  }
}
