import 'package:boldo/blocs/homeAppointments_bloc/homeAppointments_bloc.dart';
import 'package:boldo/blocs/homeNews_bloc/homeNews_bloc.dart';
import 'package:boldo/blocs/home_bloc/home_bloc.dart';
import 'package:boldo/blocs/user_bloc/patient_bloc.dart' as patientBloc;
import 'package:boldo/constants.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/News.dart';
import 'package:boldo/screens/appointments/pastAppointments_screen.dart';
import 'package:boldo/screens/dashboard/tabs/components/appointment_card.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/dashboard/tabs/components/divider_feed_secction_home.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/dashboard/tabs/components/home_tab_appbar.dart';
import 'package:boldo/screens/dashboard/tabs/doctors_tab.dart';
import 'package:boldo/screens/prescriptions/prescriptions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:isolate';
import 'package:boldo/models/Appointment.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  List<Appointment> appointments = [];
  List<DiagnosticReport> diagnosticReports = [];

  List<News> news = [];

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
      image: 'assets/images/card_medicalInspection.png',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 4,
      title: 'Ver mis estudios',
      appear: true,
      pageRoute: '/my_studies',
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
  ];

  RefreshController? _refreshController =
      RefreshController(initialRefresh: false);
  RefreshController? _refreshControllerNews =
      RefreshController(initialRefresh: false);
  DateTime dateOffset = DateTime.now().subtract(const Duration(days: 30));
  void _onRefresh() async {
    // monitor network fetch
    BlocProvider.of<HomeAppointmentsBloc>(context).add(GetAppointmentsHome());
  }

  void _onRefreshNews() async {
    // monitor network fetch
    news = [];
    BlocProvider.of<HomeNewsBloc>(context).add(GetNews());
  }

  @override
  void initState() {
    _controller = TabController(
      length: 1,
      vsync: this,
    );
    //BlocProvider.of<HomeAppointmentsBloc>(context).add(GetAppointmentsHome());
    BlocProvider.of<HomeNewsBloc>(context).add(GetNews());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<HomeBloc, HomeState>(
              listener: (context, state) {
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
                  _loading = false;
                }
                if (state is Loading) {
                  _loading = true;
                }
              },
            ),
            BlocListener<HomeNewsBloc, HomeNewsState>(
              listener: (context, state) {
                if (state is FailedLoadedNews) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.response!),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  if (_refreshControllerNews != null) {
                    _refreshControllerNews!.refreshCompleted();
                    _refreshControllerNews!.loadComplete();
                  }
                }
                if (state is NewsLoaded) {
                  //diagnosticReports = state.news;
                  news = state.news;
                  if (_refreshControllerNews != null) {
                    _refreshControllerNews!.refreshCompleted();
                    _refreshControllerNews!.loadComplete();
                  }
                }
              },
            ),
            /*BlocListener<HomeAppointmentsBloc, HomeAppointmentsState>(
              listener: (context, state) {
                if (state is FailedLoadedAppointments) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.response!),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  if (_refreshController != null) {
                    _refreshController!.refreshCompleted();
                    _refreshController!.loadComplete();
                  }
                }
                if (state is AppointmentsHomeLoaded) {
                  appointments = state.appointments;
                  news = [...news,...state.appointments];
                  if (_refreshController != null) {
                    _refreshController!.refreshCompleted();
                    _refreshController!.loadComplete();
                  }
                }
              },
            ),*/
          ],
          child: NestedScrollView(
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
                            child: Container(
                              child:
                              BlocBuilder<patientBloc.PatientBloc, patientBloc.PatientState>(builder: (context, state) {
                                if(state is patientBloc.Success){
                                  return Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Novedades${prefs.getBool(isFamily) ?? false ? " de " : ''}',
                                        style: boldoSubTextStyle.copyWith(color: ConstantsV2.inactiveText),
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
                                  );
                                }else{
                                  return Text(
                                    'Novedades',
                                    style: boldoSubTextStyle.copyWith(color: ConstantsV2.inactiveText),
                                  );
                                }
                              }),
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
                ],
              ),
            ),
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
      padding: const EdgeInsets.all(0),
      width: double.infinity,
      decoration: const BoxDecoration(
          border: Border(
              right: BorderSide(
                  color: Colors.grey, width: 1, style: BorderStyle.solid))),
      child: const Tab(
        // icon: ImageIcon(AssetImage(imagePath)),
        child: Text('test'),
      ),
    );
  }

  Widget _buildAppointments() {
    return Container(
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const MaterialClassicHeader(
          color: Constants.primaryColor800,
        ),
        controller: _refreshController!,
        onLoading: () {
          dateOffset = dateOffset.subtract(const Duration(days: 30));
        },
        onRefresh: _onRefresh,
        footer: CustomFooter(
          height: 140,
          builder: (BuildContext context, LoadStatus? mode) {
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
        child: BlocBuilder<HomeAppointmentsBloc, HomeAppointmentsState>(builder: (context, state) {
          if(state is AppointmentsHomeLoaded){
            return appointments.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              itemCount: appointments.length,
              scrollDirection: Axis.vertical,
              itemBuilder: _ListAppointments,
              physics: const ClampingScrollPhysics(),
            )
                :SingleChildScrollView(
              child: Column(
                children: [
                  const EmptyStateV2(
                    textBottom:
                    "A medida que uses la app, irás encontrando novedades tales como: "
                        "próximas consultas, recetas y resultados de estudios.",
                  ),
                ],
              ),
            );
          }else if(state is LoadingAppointments){
            return Container(
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                  backgroundColor: Constants.primaryColor600,
                )
              )
            );
          }else if(state is FailedLoadedAppointments){
            return Container(
                child: DataFetchErrorWidget(retryCallback: () => BlocProvider.of<HomeAppointmentsBloc>(context).add(GetAppointmentsHome()) ) );
          }else{
            return Container();
          }
        }),
      ),
    );
  }

  Widget _buildNews() {
    return Container(
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const MaterialClassicHeader(
          color: Constants.primaryColor800,
        ),
        controller: _refreshControllerNews!,
        onLoading: () {
        },
        onRefresh: _onRefreshNews,
        footer: CustomFooter(
          height: 140,
          builder: (BuildContext context, LoadStatus? mode) {
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
        child: BlocBuilder<HomeNewsBloc, HomeNewsState>(builder: (context, state) {
          if(state is NewsLoaded){
            return news.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              itemCount: news.length,
              scrollDirection: Axis.vertical,
              itemBuilder: _newsCard,
              physics: const ClampingScrollPhysics(),
            )
                :SingleChildScrollView(
              child: Column(
                children: [
                  const EmptyStateV2(
                    textBottom:
                    "A medida que uses la app, irás encontrando novedades tales como: "
                        "próximas consultas, recetas y resultados de estudios.",
                  ),
                ],
              ),
            );
          }else if (state is LoadingNews){
            return Container(
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                  backgroundColor: Constants.primaryColor600,
                )
              )
            );
          }else if(state is FailedLoadedNews){
            return Container(
                child: DataFetchErrorWidget(retryCallback: () => BlocProvider.of<HomeNewsBloc>(context).add(GetNews()) ) );
          }else{
            return Container();
          }
        }),
      ),
    );
  }

  Widget _newsCard(BuildContext context, int index){
    return news[index].show();
  }

  Widget _ListAppointments(BuildContext context, int index) {
    return AppointmentCard(
      appointment: appointments[index],
      isInWaitingRoom: appointments[index].status == "open",
      showCancelOption: true,
    );
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
                  if(carouselCardPage!.page != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => carouselCardPage!.page!));
                  }
                  else if(carouselCardPage!.pageRoute != null) {
                    Navigator.pushNamed(
                        context,
                        '${carouselCardPage!.pageRoute!}');
                  }
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

class CarouselCardPages extends StatelessWidget {
  final String image;
  final int index;
  final BoxFit boxFit;
  final Alignment alignment;
  final String title;
  final bool appear;
  final Widget? page;
  final String? pageRoute;

  const CarouselCardPages({
    Key? key,
    required this.image,
    required this.boxFit,
    required this.alignment,
    required this.index,
    required this.title,
    required this.appear,
    this.page,
    this.pageRoute,
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
      padding: const EdgeInsets.all(0),
      decoration: (rightDivider)
          ? const BoxDecoration(
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
