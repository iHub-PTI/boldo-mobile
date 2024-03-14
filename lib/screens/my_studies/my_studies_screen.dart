import 'package:boldo/blocs/download_studies_orders_bloc/download_studies_orders_bloc.dart' as download_studies_orders_bloc;
import 'package:boldo/blocs/studies_orders_bloc/studiesOrders_bloc.dart' as studies_orders_bloc;
import 'package:boldo/main.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:boldo/screens/my_studies/components/study_result_card.dart';
import 'package:boldo/screens/studies_orders/attach_study_by_order.dart';
import 'package:boldo/screens/studies_orders/components/studyOrderCard.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/card_button.dart';
import 'package:boldo/widgets/header_page.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:boldo/widgets/selectable/selectable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/DiagnosticReport.dart';
import 'components/new_study_button.dart';
import 'estudy_screen.dart';

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
      floatingActionButton: NewStudyButton(listener: _tabStudiesController,),
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
          if(diagnosticReport.isNotEmpty)
            return ListView.separated(
              physics: const ClampingScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) => const Divider(
                color: Colors.transparent,
                height: 10,
              ),
              itemCount: diagnosticReport.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: showStudy,
            );
          else
            return const EmptyStateV2(
              picture: "empty_studies.svg",
              titleBottom: "Aún no tenés estudios",
              textBottom:
              "A medida en que uses la aplicación podrás ir viendo tus estudios",
            );
        }
      },
    );
  }

  Widget studiesOrders(){
    return BlocBuilder<studies_orders_bloc.StudiesOrdersBloc, studies_orders_bloc.StudiesOrdersState>(
      builder: (BuildContext context, state){
        if(state is studies_orders_bloc.StudiesOrdersLoaded){
          return state.studiesOrders.isNotEmpty ? SelectableWidgets<ServiceRequest, download_studies_orders_bloc.Loading>(
            downloadEvent: (ids){
              return download_studies_orders_bloc.DownloadStudiesOrders(
                listOfIds: ids,
                context: context,
              );
            },
            bloc: download_studies_orders_bloc.DownloadStudiesOrdersBloc(),
            items: (state.studiesOrders?? []).map((e) {
              return SelectableWidgetItem<ServiceRequest>(
                child: ServiceRequestCard(
                  serviceRequest: e,
                ),
                item: e,
                id: e.id,
              );
            }).toList(),
          ): const EmptyStateV2(
            picture: "empty_studies.svg",
            titleBottom: "Aún no tenés órdenes",
            textBottom:
            "Aquí aparecerán las órdenes de estudios solicitadas",
          );
        } else if(state is studies_orders_bloc.LoadingOrders) {
          return loadingStatus();
        } else {
          return Container();
        }
      });
  }

  Widget showStudy(BuildContext context, int index) {
    return StudyResultCard(
      diagnosticReport: diagnosticReport[index],
    );
  }

  Widget showStudyOrder({required ServiceRequest serviceRequest}) {
    return ServiceRequestCard(
      serviceRequest: serviceRequest,
    );
  }
}
