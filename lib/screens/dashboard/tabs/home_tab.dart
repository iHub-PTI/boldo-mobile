import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/screens/appointments/pastAppointments_screen.dart';
import 'package:boldo/screens/dashboard/tabs/components/appointment_card.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/dashboard/tabs/components/divider_feed_secction_home.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/dashboard/tabs/components/home_tab_appbar.dart';
import 'package:boldo/screens/dashboard/tabs/doctors_tab.dart';
import 'package:boldo/screens/my_studies/my_studies_screen.dart';
import 'package:boldo/screens/prescriptions/prescriptions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:boldo/network/http.dart';

import '../../../main.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  late TabController _controller;

  List<Appointment> allAppointmentsState = [];
  List<Appointment> nextAppointments = [];
  List<Appointment> upcomingWaitingRoomAppointments = [];
  List<Appointment> waitingRoomAppointments = [];
  List<Appointment> appointments = [];
  List<DiagnosticReport> diagnosticReports = [];

  List<Appointment> news = [];

  bool _dataFetchError = false;
  bool _loading = true;
  double _heightExpandedCarousel = ConstantsV2.homeExpandedMaxHeight;
  double _heightAppBarExpandable = ConstantsV2.homeAppBarMaxHeight;
  double _heightCarouselTitleExpandable =
      ConstantsV2.homeCarouselTitleContainerMaxHeight;
  double _heightCarouselExpandable = ConstantsV2.homeCarouselContainerMaxHeight;

  double _heightCarouselCard = ConstantsV2.homeCarouselCardMaxHeight;
  double _widthCarouselCard = ConstantsV2.homeCarouselCardMaxWidth;
  double _radiusCarouselCard = ConstantsV2.homeCarouselCardMinRadius;

  final List<CarouselCardPages> items = [
    CarouselCardPages(
      key: UniqueKey(),
      image: 'assets/images/card_appointment.png',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 0,
      title: 'Agendar una consulta',
      appear: true,
      page: DoctorsTab(),
    ),
    CarouselCardPages(
      key: UniqueKey(),
      image: 'assets/images/card_medicalStudies.png',
      boxFit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      index: 1,
      title: 'Ver mis consultas',
      appear: true,
      page: const PastAppointmentsScreen(),
    ),
    CarouselCardPages(
      key: UniqueKey(),
      image: 'assets/images/card_prescriptions.png',
      boxFit: BoxFit.cover,
      alignment: Alignment.centerLeft,
      index: 2,
      title: 'Ver mis recetas',
      appear: true,
      page: const PrescriptionsScreen(),
    ),
    CarouselCardPages(
      key: UniqueKey(),
      image: 'assets/images/card_healthPassport.png',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 3,
      title: 'Pasaporte de salud',
      appear: false,
      page: DoctorsTab(),
    ),
    CarouselCardPages(
      key: UniqueKey(),
      image: 'assets/images/card_medicalInspection.png',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 4,
      title: 'Ver mis estudios',
      appear: true,
      page: MyStudies(),
    ),
  ];

  RefreshController? _refreshController =
      RefreshController(initialRefresh: false);
  RefreshController? _refreshControllerNews =
      RefreshController(initialRefresh: false);
  DateTime dateOffset = DateTime.now().subtract(const Duration(days: 30));
  void _onRefresh() async {
    setState(() {
      dateOffset = DateTime.now().subtract(const Duration(days: 30));
    });
    // monitor network fetch
    await getAppointmentsData(loadMore: false);
  }

  void _onRefreshNews() async {
    setState(() {
      dateOffset = DateTime.now().subtract(const Duration(days: 30));
    });
    // monitor network fetch
    await getdiagnosticReport(loadMore: false);
  }

  @override
  void initState() {
    _controller = TabController(
      length: 2,
      vsync: this,
    );
    getAppointmentsData(loadMore: false);
    getdiagnosticReport(loadMore: false);
    super.initState();
  }

  @override
  void dispose() {
    if (_isolate != null) {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
    }
    if (_receivePort != null) {
      _receivePort?.close();
      _receivePort = null;
    }

    super.dispose();
  }

  static void _updateWaitingRoomsList(Map map) async {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      for (Appointment appointment in map["upcomingWaitingRoomAppointments"]) {
        if (DateTime.now()
            .add(const Duration(minutes: 15))
            .isAfter(DateTime.parse(appointment.start!).toLocal())) {
          timer.cancel();
          map['port'].send({"newAppointment": appointment});
          break;
        }
      }
    });
  }

  void _handleWaitingRoomsListUpdate(dynamic data) async {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    //if appointment doesnt exist in the list of appointments then update the state
    bool hasAppointment = waitingRoomAppointments
        .any((element) => element.id == data["newAppointment"].id);
    List<Appointment> updatedUpcomingAppointments =
        upcomingWaitingRoomAppointments
            .where((element) => element.id != data["newAppointment"].id)
            .toList();
    if (!mounted) return;
    if (!hasAppointment) {
      setState(() {
        upcomingWaitingRoomAppointments = updatedUpcomingAppointments;
        waitingRoomAppointments = [
          ...waitingRoomAppointments,
          data["newAppointment"]
        ];
      });
    }
    if (updatedUpcomingAppointments.isEmpty) return;
    _receivePort = ReceivePort();
    // restart the isolate with new data
    _isolate = await Isolate.spawn(
      _updateWaitingRoomsList,
      {
        'port': _receivePort?.sendPort,
        'upcomingWaitingRoomAppointments': updatedUpcomingAppointments,
      },
    );
    _receivePort?.listen(_handleWaitingRoomsListUpdate);
  }

  Future<void> getAppointmentsData({bool loadMore = false}) async {
    if (!loadMore) {
      if (_isolate != null) {
        _isolate!.kill(priority: Isolate.immediate);
        _isolate = null;
      }
      if (_receivePort != null) {
        _receivePort!.close();
        _receivePort = null;
      }
      if (!mounted) return;
      setState(() {
        _loading = true;
        _dataFetchError = false;
      });
    }
    Response responseAppointments;
    try {
      if (!prefs.getBool(isFamily)!)
        responseAppointments = await dio.get(
            "/profile/patient/appointments?start=${DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toUtc().toIso8601String()}");
      else
        responseAppointments = await dio.get(
            "/profile/caretaker/dependent/${patient.id}/appointments?start=${DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toUtc().toIso8601String()}");

      /*Response responsePrescriptions =
          await dio.get("/profile/patient/prescriptions");
      List<Prescription> allPrescriptions = List<Prescription>.from(
          responsePrescriptions.data["prescriptions"]
              .map((i) => Prescription.fromJson(i)));*/
      List<Appointment> allAppointmets = List<Appointment>.from(
          responseAppointments.data["appointments"]
              .map((i) => Appointment.fromJson(i)));

      /*for (Appointment appointment in allAppointmets) {
        for (Prescription prescription in allPrescriptions) {
          if (prescription.encounter != null &&
              prescription.encounter!.appointmentId == appointment.id) {
            if (appointment.prescriptions != null) {
              appointment.prescriptions = [
                ...appointment.prescriptions!,
                prescription
              ];
            } else {
              appointment.prescriptions = [prescription];
            }
          }
        }
      }*/

      if (!mounted) return;

      // Past appointment will be ignored
      /*List<Appointment> pastAppointmentsItems = allAppointmets
          .where((element) => ["closed", "locked"].contains(element.status))
          .toList();*/

      // Appointments cancelled will be ignored
      List<Appointment> upcomingAppointmentsItems = allAppointmets
          .where((element) =>
              !["closed", "locked", "cancelled"].contains(element.status))
          .toList();
      allAppointmets = [
        ...upcomingAppointmentsItems, /*...pastAppointmentsItems*/
      ];

      allAppointmets.sort((a, b) =>
          DateTime.parse(b.start!).compareTo(DateTime.parse(a.start!)));

      appointments = allAppointmets
          .where((element) =>
              !["closed", "locked", "cancelled"].contains(element.status))
          .toList();
      appointments.sort((a, b) =>
          DateTime.parse(a.start!).compareTo(DateTime.parse(b.start!)));

      List<Appointment> upcomingWaitingRoomAppointmetsList = allAppointmets
          .where((element) =>
              element.status == "upcoming" &&
              DateTime.now()
                  .add(const Duration(minutes: 15))
                  .isBefore(DateTime.parse(element.start!).toLocal()))
          .toList();
      if (!mounted) return;
      if (!loadMore) {
        _receivePort = ReceivePort();
        _isolate = await Isolate.spawn(
          _updateWaitingRoomsList,
          {
            'port': _receivePort?.sendPort,
            'upcomingWaitingRoomAppointments':
                upcomingWaitingRoomAppointmetsList,
          },
        );
        _receivePort?.listen(_handleWaitingRoomsListUpdate);
      }

      if (!mounted) return;
      setState(() {
        _dataFetchError = false;
        _loading = false;
        upcomingWaitingRoomAppointments = upcomingWaitingRoomAppointmetsList;
        waitingRoomAppointments = allAppointmets.where(
          (element) {
            if (element.status == "open") {
              return true;
            }

            if (element.status == "upcoming" &&
                DateTime.now()
                    .add(const Duration(minutes: 15))
                    .isAfter(DateTime.parse(element.start!).toLocal())) {
              return true;
            }
            return false;
          },
        ).toList();

        allAppointmentsState = [
          ...allAppointmets,
        ];
        Appointment firstPastAppointment = allAppointmentsState.firstWhere(
            (element) => ["closed", "locked"].contains(element.status),
            orElse: () => Appointment());
        nextAppointments = [];
        for (int i = 0; i < allAppointmentsState.length; i++) {
          if (firstPastAppointment.id != allAppointmentsState[i].id) {
            nextAppointments.add(allAppointmentsState[i]);
          } else {
            break;
          }
        }
        nextAppointments = nextAppointments.reversed.toList();
      });
    } on DioError catch (exception, stackTrace) {
      print(exception);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _dataFetchError = true;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _dataFetchError = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } finally {
      if (_refreshController != null) {
        _refreshController!.refreshCompleted();
        _refreshController!.loadComplete();
      }
    }
  }

  Future<void> getdiagnosticReport({bool loadMore = false}) async {

    Response responseAppointments;
    try {
      if (!prefs.getBool(isFamily)!)
        responseAppointments = await dio.get(
            "/profile/patient/diagnosticReports");
      else
        responseAppointments = await dio.get(
            "/profile/caretaker/dependent/${patient.id}/diagnosticReports");

      List<DiagnosticReport> allDiagnosticReports = List<DiagnosticReport>.from(
          responseAppointments.data
              .map((i) => DiagnosticReport.fromJson(i)));
      setState(() {
        diagnosticReports = allDiagnosticReports.where((element) => element.sourceID != patient.id).toList();
      });

    }catch (e){

    }finally {
      if (_refreshControllerNews != null) {
        _refreshControllerNews!.refreshCompleted();
        _refreshControllerNews!.loadComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<PatientBloc, PatientState>(
          listener: (context, state) {
            setState(() {
              if (state is Failed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.response!),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                _loading = false;
              }
              if (state is Success) {
                setState(() {
                  _loading = true;
                  getAppointmentsData();
                  _loading = false;
                });
              }
              if (state is RedirectNextScreen) {
                // back to home
                Navigator.pop(context);
              }
              if (state is Loading) {
                _loading = true;
              }
            });
          },
          child:
              BlocBuilder<PatientBloc, PatientState>(builder: (context, state) {
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) => [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: ConstantsV2.homeExpandedMaxHeight,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  leadingWidth: double.infinity,
                  toolbarHeight: ConstantsV2.homeExpandedMinHeight,
                  flexibleSpace: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    _heightExpandedCarousel = constraints.biggest.height;
                    _heightAppBarExpandable = ConstantsV2.homeAppBarMaxHeight -
                        (ConstantsV2.homeAppBarMaxHeight -
                                ConstantsV2.homeAppBarMinHeight) *
                            ((ConstantsV2.homeExpandedMaxHeight -
                                    constraints.biggest.height) /
                                (ConstantsV2.homeExpandedMaxHeight -
                                    ConstantsV2.homeExpandedMinHeight));
                    _heightCarouselTitleExpandable =
                        ConstantsV2.homeCarouselTitleContainerMaxHeight -
                            (ConstantsV2.homeCarouselTitleContainerMaxHeight -
                                    ConstantsV2
                                        .homeCarouselTitleContainerMinHeight) *
                                ((ConstantsV2.homeExpandedMaxHeight -
                                        constraints.biggest.height) /
                                    (ConstantsV2.homeExpandedMaxHeight -
                                        ConstantsV2.homeExpandedMinHeight));
                    _heightCarouselExpandable = ConstantsV2
                            .homeCarouselContainerMaxHeight -
                        (ConstantsV2.homeCarouselContainerMaxHeight -
                                ConstantsV2.homeCarouselContainerMinHeight) *
                            ((ConstantsV2.homeExpandedMaxHeight -
                                    constraints.biggest.height) /
                                (ConstantsV2.homeExpandedMaxHeight -
                                    ConstantsV2.homeExpandedMinHeight));
                    _heightCarouselCard =
                        ConstantsV2.homeCarouselCardMaxHeight -
                            (ConstantsV2.homeCarouselCardMaxHeight -
                                    ConstantsV2.homeCarouselCardMinHeight) *
                                ((ConstantsV2.homeExpandedMaxHeight -
                                        constraints.biggest.height) /
                                    (ConstantsV2.homeExpandedMaxHeight -
                                        ConstantsV2.homeExpandedMinHeight));
                    _widthCarouselCard = ConstantsV2.homeCarouselCardMaxWidth -
                        (ConstantsV2.homeCarouselCardMaxWidth -
                                ConstantsV2.homeCarouselCardMinWidth) *
                            ((ConstantsV2.homeExpandedMaxHeight -
                                    constraints.biggest.height) /
                                (ConstantsV2.homeExpandedMaxHeight -
                                    ConstantsV2.homeExpandedMinHeight));
                    _radiusCarouselCard =
                        ConstantsV2.homeCarouselCardMinRadius +
                            (ConstantsV2.homeCarouselCardMaxRadius -
                                    ConstantsV2.homeCarouselCardMinRadius) *
                                ((ConstantsV2.homeExpandedMaxHeight -
                                        constraints.biggest.height) /
                                    (ConstantsV2.homeExpandedMaxHeight -
                                        ConstantsV2.homeExpandedMinHeight));

                    return Column(children: [
                      HomeTabAppBar(max: _heightAppBarExpandable),
                      DividerFeedSectionHome(
                          text: "¿Qué desea hacer?",
                          height: _heightCarouselTitleExpandable),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: _heightCarouselExpandable,
                        child: Container(
                          height: _heightCarouselCard,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: items.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: _buildCarousel,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                            width: double.maxFinite,
                            height: ConstantsV2.homeFeedTitleContainerMaxHeight,
                            padding: const EdgeInsetsDirectional.all(16),
                            decoration: const BoxDecoration(
                              color: ConstantsV2.lightGrey,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                    child: SvgPicture.asset(
                                  'assets/decorations/line_separator.svg',
                                )),
                                TabBar(
                                  indicatorColor: Colors.transparent,
                                  unselectedLabelColor:
                                      const Color.fromRGBO(119, 119, 119, 1),
                                  labelColor: Colors.black,
                                  controller: _controller,
                                  tabs: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Novedades${prefs.getBool(isFamily) ?? false ? " de " : ''}',
                                        ),
                                        prefs.getBool(isFamily) ?? false
                                            ? Text(
                                                '${patient.relationshipDisplaySpan}',
                                                style: boldoCorpMediumTextStyle
                                                    .copyWith(
                                                        color:
                                                            ConstantsV2.green))
                                            : Container(),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Citas',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ]);
                  }),
                ),
              ],
              body: TabBarView(
                controller: _controller,
                children: [
                  _buildNews(),
                  _buildAppointments(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, int carouselIndex) {
    return CustomCardPage(
      carouselCardPage: items[carouselIndex],
      height: _heightCarouselCard,
      width: _widthCarouselCard,
      radius: _radiusCarouselCard,
    );
  }

  Widget _individualTab() {
    return Container(
      height: 50 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.all(0),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border(
              right: BorderSide(
                  color: Colors.grey, width: 1, style: BorderStyle.solid))),
      child: Tab(
        // icon: ImageIcon(AssetImage(imagePath)),
        child: Text('test'),
      ),
    );
  }

  Widget _buildAppointments() {
    return _dataFetchError
        ? Container(
            child: DataFetchErrorWidget(retryCallback: getAppointmentsData))
        : _loading
            ? Container(
                child: const Center(
                    child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                backgroundColor: Constants.primaryColor600,
              )))
            : Container(
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  header: const MaterialClassicHeader(
                    color: Constants.primaryColor800,
                  ),
                  controller: _refreshController!,
                  onLoading: () {
                    dateOffset = dateOffset.subtract(const Duration(days: 30));
                    setState(() {});
                    //getAppointmentsData(loadMore: true);
                  },
                  onRefresh: _onRefresh,
                  footer: CustomFooter(
                    height: 140,
                    builder: (BuildContext context, LoadStatus? mode) {
                      print(mode);
                      Widget body = Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*Text(
                  "Mostrando datos hasta ${DateFormat('dd MMMM yyyy').format(dateOffset)}",
                  style: const TextStyle(
                    color: Constants.primaryColor800,
                  ),
                )*/
                        ],
                      );
                      return Column(
                        children: [
                          const SizedBox(height: 30),
                          Center(child: body),
                        ],
                      );
                    },
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (allAppointmentsState.isNotEmpty)
                          for (int i = 0; i < appointments.length; i++)
                            _ListAppointments(
                              appointment: appointments[i],
                            ),
                        if (allAppointmentsState.isEmpty)
                          const EmptyStateV2(
                            picture: "feed_empty.svg",
                            textTop: "Nada para mostrar",
                            textBottom:
                                "A medida que uses la app, las novedades se van a ir mostrando en esta sección",
                          ),
                      ],
                    ),
                  ),
                ),
              );
  }

  Widget _buildNews() {
    return _dataFetchError
        ? Container(
            child: DataFetchErrorWidget(retryCallback: getdiagnosticReport))
        : _loading
            ? Container(
                child: const Center(
                    child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                backgroundColor: Constants.primaryColor600,
              )))
            : Container(
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  header: const MaterialClassicHeader(
                    color: Constants.primaryColor800,
                  ),
                  controller: _refreshControllerNews!,
                  onLoading: () {
                    //getAppointmentsData(loadMore: true);
                  },
                  onRefresh: _onRefreshNews,
                  footer: CustomFooter(
                    height: 140,
                    builder: (BuildContext context, LoadStatus? mode) {
                      print(mode);
                      Widget body = Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*Text(
                  "Mostrando datos hasta ${DateFormat('dd MMMM yyyy').format(dateOffset)}",
                  style: const TextStyle(
                    color: Constants.primaryColor800,
                  ),
                )*/
                        ],
                      );
                      return Column(
                        children: [
                          const SizedBox(height: 30),
                          Center(child: body),
                        ],
                      );
                    },
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (diagnosticReports.isNotEmpty)
                          for (int i = 0; i < diagnosticReports.length; i++)
                            _diagnosticReportCard(diagnosticReports[i],
                            ),
                        if (diagnosticReports.isEmpty)
                          const EmptyStateV2(
                            picture: "feed_empty.svg",
                            textTop: "Nada para mostrar",
                            textBottom:
                                "A medida que uses la app, las novedades se van a ir mostrando en esta sección",
                          ),
                      ],
                    ),
                  ),
                ),
              );
  }

  Widget _diagnosticReportCard(DiagnosticReport diagnosticReport){
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
                        child: Text("${DateFormat('dd/MM/yy').format(DateTime.parse(diagnosticReport.effectiveDate!).toLocal())}",
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
                                diagnosticReport.type == "LABORATORY"
                                    ? 'assets/icon/lab.svg'
                                    : diagnosticReport.type == "IMAGE"
                                    ? 'assets/icon/image.svg'
                                    : diagnosticReport.type == "OTHER"
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
                          Text("${diagnosticReport.description}",
                            style: boldoCorpMediumTextStyle.copyWith(
                                color: ConstantsV2.inactiveText
                            ),
                          ),
                          Text("Subido por ${diagnosticReport.source}",
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
                                Text("${diagnosticReport.attachmentNumber} ${diagnosticReport.attachmentNumber== "1" ? "archivo adjunto": "archivos adjuntos"}",
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

class _ListAppointments extends StatelessWidget {
  final Appointment appointment;

  const _ListAppointments({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AppointmentCard(
        appointment: appointment,
        isInWaitingRoom: appointment.status == "open",
        showCancelOption: true,
      ),
    ]);
  }
}

class CustomCardPage extends StatefulWidget {
  final CarouselCardPages? carouselCardPage;
  final double height;
  final double width;
  final double radius;

  const CustomCardPage({
    Key? key,
    required this.carouselCardPage,
    required this.height,
    required this.width,
    required this.radius,
  }) : super(key: key);

  @override
  State<CustomCardPage> createState() =>
      _CustomCardPageState(carouselCardPage: carouselCardPage);
}

class _CustomCardPageState extends State<CustomCardPage> {
  // text and image
  CarouselCardPages? carouselCardPage;
  _CustomCardPageState({required this.carouselCardPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: widget.width,
          maxHeight: widget.height,
          minHeight: widget.height,
          minWidth: widget.width),
      child: Card(
        margin: const EdgeInsets.all(6),
        clipBehavior: Clip.antiAlias,
        shape: widget.radius < 70
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.radius),
              )
            : const StadiumBorder(),
        child: InkWell(
          onTap: carouselCardPage!.appear
              ? () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => carouselCardPage!.page!));
                }
              : () {},
          child: Container(
            child: Stack(
              children: [
                // Container that define the image background
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: carouselCardPage!.appear
                          ? null
                          : widget.radius < 70
                              ? null
                              : const ColorFilter.mode(
                                  Colors.black, BlendMode.hue),
                      image: AssetImage(carouselCardPage!.image),
                    ),
                  ),
                ),
                Container(
                  decoration: widget.radius < 70
                      ? BoxDecoration(
                          // Background linear gradient
                          gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: <Color>[
                              Colors.black,
                              Colors.black.withOpacity(0.01),
                            ],
                              stops: <double>[
                              -.0159,
                              0.9034,
                            ]))
                      : null,
                ),
                // Container used for group text info
                Container(
                    padding: const EdgeInsets.only(
                        left: 6, right: 6, bottom: 7, top: 7),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          carouselCardPage!.appear
                              ? const Text("")
                              : AnimatedOpacity(
                                  opacity: widget.radius < 70 ? 1 : 0,
                                  duration: const Duration(milliseconds: 1),
                                  child: widget.radius < 70
                                      ? CardNotAvailable()
                                      : null,
                                ),
                          Flexible(
                            child: AnimatedOpacity(
                              opacity: widget.radius < 70 ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                carouselCardPage!.title,
                                style: boldoCorpMediumBlackTextStyle,
                              ),
                            ),
                          ),
                        ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardNotAvailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: ConstantsV2.green,
      child: Container(
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2, top: 2),
        child: const Text(
          "Proximamente",
          style: TextStyle(
            color: ConstantsV2.lightGrey,
            fontStyle: FontStyle.normal,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}

/*
class _ListRenderer extends StatelessWidget {
  final int index;
  final Appointment appointment;
  final Appointment? firstAppointmentPast;
  final List<Appointment> waitingRoomAppointments;

  const _ListRenderer(
      {Key? key,
      required this.index,
      required this.appointment,
      required this.firstAppointmentPast,
      required this.waitingRoomAppointments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isInWaitingRoom =
        waitingRoomAppointments.any((element) => element.id == appointment.id);
    if (index == 0 && !["closed", "locked"].contains(appointment.status))
      return Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 18),
            child: Text(
              "Próximas Citas",
              style: boldoSubTextStyle.copyWith(
                fontSize: 14,
                color: const Color(0xff6B7280),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 18,
            top: 7,
            left: 10,
            right: 10,
          ),
          width: double.infinity,
          color: const Color(0xffE5E7EB),
          height: 1,
        ),
        AppointmentCard(
          appointment: appointment,
          isInWaitingRoom: isInWaitingRoom,
          showCancelOption: true,
        ),
      ]);
    if (firstAppointmentPast != null &&
        firstAppointmentPast!.id == appointment.id) {
      return Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 18),
            child: Text(
              "Citas Pasadas",
              style: boldoSubTextStyle.copyWith(
                fontSize: 14,
                color: const Color(0xff6B7280),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 18,
            top: 7,
            left: 10,
            right: 10,
          ),
          width: double.infinity,
          color: const Color(0xffE5E7EB),
          height: 1,
        ),
        AppointmentCard(
          appointment: appointment,
          isInWaitingRoom: isInWaitingRoom,
          showCancelOption: false,
        ),
      ]);
    }
    return AppointmentCard(
      appointment: appointment,
      isInWaitingRoom: isInWaitingRoom,
      showCancelOption: true,
    );
  }
}*/

class CarouselCardPages extends StatelessWidget {
  final String image;
  final int index;
  final BoxFit boxFit;
  final Alignment alignment;
  final String title;
  final bool appear;
  final Widget? page;

  const CarouselCardPages({
    Key? key,
    required this.image,
    required this.boxFit,
    required this.alignment,
    required this.index,
    required this.title,
    required this.appear,
    this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(image, fit: boxFit, alignment: alignment);
  }
}

class TabWidget extends StatelessWidget {
  final String label;
  final bool rightDivider;

  TabWidget({
    required this.label,
    required this.rightDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32 + MediaQuery.of(context).padding.bottom,
      width: double.infinity,
      padding: EdgeInsets.all(0),
      decoration: (rightDivider)
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            )
          : null,
      child: Center(child: Text(label)),
    );
  }
}
