import 'package:boldo/blocs/homeNews_bloc/homeNews_bloc.dart';
import 'package:boldo/blocs/homeOrganization_bloc/homeOrganization_bloc.dart';
import 'package:boldo/blocs/home_bloc/home_bloc.dart';
import 'package:boldo/blocs/user_bloc/patient_bloc.dart' as patientBloc;
import 'package:boldo/constants.dart';
import 'package:boldo/models/DiagnosticReport.dart';
import 'package:boldo/models/News.dart';
import 'package:boldo/screens/appointments/pastAppointments_screen.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/dashboard/tabs/components/divider_feed_secction_home.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/dashboard/tabs/components/home_tab_appbar.dart';
import 'package:boldo/screens/dashboard/tabs/doctors_tab.dart';
import 'package:boldo/screens/organizations/memberships_screen.dart';
import 'package:boldo/screens/doctor_search/doctors_available.dart';
import 'package:boldo/screens/passport/passport.dart';
import 'package:boldo/screens/prescriptions/prescriptions_screen.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/go_to_top.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:isolate';
import 'package:boldo/models/Appointment.dart';
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
  // controller for scroll
  ScrollController homeScroll = ScrollController();
  // flag for show or not the button
  bool showAnimatedButton = false;

  List<Appointment> appointments = [];
  List<DiagnosticReport> diagnosticReports = [];

  List<News> news = [];

  double _heightExpandableBarMax = ConstantsV2.homeExpandedMaxHeight;
  double _heightExpandableBarMin = ConstantsV2.homeExpandedMinHeight;

  double _heightExpandedCarousel = ConstantsV2.homeExpandedMaxHeight;
  double _heightAppBarExpandable = ConstantsV2.homeAppBarMaxHeight;
  double _heightCarouselTitleExpandable =
      ConstantsV2.homeCarouselTitleContainerMaxHeight;
  double _heightCarouselExpandable = ConstantsV2.homeCarouselContainerMaxHeight;

  double _heightCarouselCard = ConstantsV2.homeCarouselCardMaxHeight;
  double _widthCarouselCard = ConstantsV2.homeCarouselCardMaxWidth;
  double _radiusCarouselCard = ConstantsV2.homeCarouselCardMinRadius;

  final List<CarouselCard> items = [
    CarouselCard(
      key: UniqueKey(),
      image: 'assets/images/card_appointment.png',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 0,
      title: 'Agendar una consulta',
      appear: true,
      requiredOrganization: true,
      //page: DoctorsTab(),
      page: DoctorsAvailable(callFromHome: true),
    ),
    CarouselCard(
      key: UniqueKey(),
      image: 'assets/images/card_medicalStudies.png',
      boxFit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      index: 1,
      title: 'Ver mis consultas',
      appear: true,
      page: const PastAppointmentsScreen(),
    ),
    CarouselCard(
      key: UniqueKey(),
      image: 'assets/images/card_prescriptions.png',
      boxFit: BoxFit.cover,
      alignment: Alignment.centerLeft,
      index: 2,
      title: 'Ver mis recetas',
      appear: true,
      page: const PrescriptionsScreen(),
    ),
    CarouselCard(
      key: UniqueKey(),
      image: 'assets/images/card_medicalInspection.png',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 4,
      title: 'Ver mis estudios',
      appear: true,
      pageRoute: '/my_studies',
    ),
    CarouselCard(
      key: UniqueKey(),
      image: 'assets/images/card_healthPassport.png',
      boxFit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      index: 3,
      title: 'Ver mis vacunas',
      appear: true,
      page: PassportTab(),
    ),
  ];

  RefreshController? _refreshControllerNews =
      RefreshController(initialRefresh: false);

  RefreshController? _refreshControllerOrganizationsCheck =
      RefreshController(initialRefresh: false);

  void _onRefreshOrganizationsCheck() async {
    // monitor network fetch
    BlocProvider.of<HomeOrganizationBloc>(context).add(GetOrganizationsSubscribed());
  }

  DateTime dateOffset = DateTime.now().subtract(const Duration(days: 30));

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
    homeScroll.addListener(() {
      double offset = 10.0; // or the value you want
      if (homeScroll.offset > offset) {
        showAnimatedButton = true;
        // this we use to get update the state
        setState(() {});
      } else {
        showAnimatedButton = false;
        setState(() {});
      }
    });
    // get organizations
    BlocProvider.of<HomeOrganizationBloc>(context).add(GetOrganizationsSubscribed());
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
      backgroundColor: ConstantsV2.grayLight,
      floatingActionButton:
          buttonGoTop(homeScroll, 1000, 500, showAnimatedButton),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<HomeOrganizationBloc, HomeOrganizationBlocState>(
              listener: (context, state) {
                if (state is HomeOrganizationFailed) {

                  // set normal height
                  _heightExpandableBarMax = ConstantsV2.homeExpandedMaxHeight;
                  _heightExpandableBarMin = ConstantsV2.homeExpandedMinHeight;

                  emitSnackBar(
                      context: context,
                      text: state.response,
                      status: ActionStatus.Fail
                  );
                  if (_refreshControllerOrganizationsCheck != null) {
                    _refreshControllerOrganizationsCheck!.refreshCompleted();
                    _refreshControllerOrganizationsCheck!.loadComplete();
                  }
                }
                if (state is OrganizationsObtained) {
                  // establish in Patient Bloc his/her list of subscribing organizations
                  BlocProvider.of<patientBloc.PatientBloc>(context)
                      .setOrganizations(state.organizationsList);

                  // reduce height to remove header for news
                  if(state.organizationsList.isEmpty) {
                    _heightExpandableBarMax = ConstantsV2.homeExpandedMaxHeight -
                        ConstantsV2.homeFeedTitleContainerMaxHeight;
                    _heightExpandableBarMin = ConstantsV2.homeExpandedMinHeight -
                        ConstantsV2.homeFeedTitleContainerMinHeight;
                  }else{
                    // set normal height
                    _heightExpandableBarMax = ConstantsV2.homeExpandedMaxHeight;
                    _heightExpandableBarMin = ConstantsV2.homeExpandedMinHeight;
                    BlocProvider.of<HomeNewsBloc>(context).add(GetNews());
                  }


                  if (_refreshControllerOrganizationsCheck != null) {
                    _refreshControllerOrganizationsCheck!.refreshCompleted();
                    _refreshControllerOrganizationsCheck!.loadComplete();
                  }
                  BlocProvider.of<HomeBloc>(context).add(ReloadHome());
                }
                if (state is HomeOrganizationLoading) {
                  // set normal height
                  _heightExpandableBarMax = ConstantsV2.homeExpandedMaxHeight;
                  _heightExpandableBarMin = ConstantsV2.homeExpandedMinHeight;
                }
              },
            ),
            BlocListener<HomeBloc, HomeState>(
              listener: (context, state) {
                if (state is ReloadHome) {
                  setState(() {

                  });
                }
              },
            ),
            BlocListener<HomeNewsBloc, HomeNewsState>(
              listener: (context, state) {
                if (state is FailedLoadedNews) {
                  emitSnackBar(
                      context: context,
                      text: state.response,
                      status: ActionStatus.Fail
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
          ],
          child: NestedScrollView(
            controller: homeScroll,
              headerSliverBuilder: (context, innerBoxScrolled) => [
                BlocBuilder<HomeOrganizationBloc,HomeOrganizationBlocState>(
                  builder: (context, state){
                    return SliverAppBar(
                      pinned: true,
                      floating: false,
                      expandedHeight: _heightExpandableBarMax,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white,
                      leadingWidth: double.infinity,
                      toolbarHeight: _heightExpandableBarMin,
                      flexibleSpace: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        _heightExpandedCarousel = constraints.biggest.height;
                        _heightAppBarExpandable = ConstantsV2.homeAppBarMaxHeight -
                            (ConstantsV2.homeAppBarMaxHeight -
                                ConstantsV2.homeAppBarMinHeight) *
                                ((_heightExpandableBarMax -
                                    constraints.biggest.height) /
                                    (_heightExpandableBarMax -
                                        _heightExpandableBarMin));
                        _heightCarouselTitleExpandable =
                            ConstantsV2.homeCarouselTitleContainerMaxHeight -
                                (ConstantsV2.homeCarouselTitleContainerMaxHeight -
                                    ConstantsV2
                                        .homeCarouselTitleContainerMinHeight) *
                                    ((_heightExpandableBarMax -
                                        constraints.biggest.height) /
                                        (_heightExpandableBarMax -
                                            _heightExpandableBarMin));
                        _heightCarouselExpandable = ConstantsV2
                            .homeCarouselContainerMaxHeight -
                            (ConstantsV2.homeCarouselContainerMaxHeight -
                                ConstantsV2.homeCarouselContainerMinHeight) *
                                ((_heightExpandableBarMax -
                                    constraints.biggest.height) /
                                    (_heightExpandableBarMax -
                                        _heightExpandableBarMin));
                        _heightCarouselCard =
                            ConstantsV2.homeCarouselCardMaxHeight -
                                (ConstantsV2.homeCarouselCardMaxHeight -
                                    ConstantsV2.homeCarouselCardMinHeight) *
                                    ((_heightExpandableBarMax -
                                        constraints.biggest.height) /
                                        (_heightExpandableBarMax -
                                            _heightExpandableBarMin));
                        _widthCarouselCard = ConstantsV2.homeCarouselCardMaxWidth -
                            (ConstantsV2.homeCarouselCardMaxWidth -
                                ConstantsV2.homeCarouselCardMinWidth) *
                                ((_heightExpandableBarMax -
                                    constraints.biggest.height) /
                                    (_heightExpandableBarMax -
                                        _heightExpandableBarMin));
                        _radiusCarouselCard =
                            ConstantsV2.homeCarouselCardMinRadius +
                                (ConstantsV2.homeCarouselCardMaxRadius -
                                    ConstantsV2.homeCarouselCardMinRadius) *
                                    ((_heightExpandableBarMax -
                                        constraints.biggest.height) /
                                        (_heightExpandableBarMax -
                                            _heightExpandableBarMin));

                        return Column(children: [
                          HomeTabAppBar(max: _heightAppBarExpandable),
                          Container(
                            height: 24,
                            decoration: const BoxDecoration(
                              color: ConstantsV2.lightGrey,
                            ),
                          ),
                          DividerFeedSectionHome(
                            text: "¿Qué desea hacer?",
                            height: _heightCarouselTitleExpandable,
                          ),
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
                          Container(
                            height: 24,
                            decoration: const BoxDecoration(
                              color: ConstantsV2.lightGrey,
                            ),
                          ),
                          //header
                          BlocBuilder<HomeOrganizationBloc,HomeOrganizationBlocState>(
                            builder: (context, state){
                              //show header if the patient has organization
                              if(state is OrganizationsObtained) {
                                if (BlocProvider.of<patientBloc.PatientBloc>(context)
                                    .getOrganizations().isNotEmpty){
                                  return BlocBuilder<patientBloc.PatientBloc, patientBloc.PatientState>(
                                      builder: (context, state) {
                                        if(BlocProvider.of<patientBloc.PatientBloc>(context)
                                            .getOrganizations().isNotEmpty) {
                                          if (state is patientBloc.Success) {
                                            return SizedBox(
                                              width: double.infinity,
                                              child: Container(
                                                  width: double.maxFinite,
                                                  height: ConstantsV2.homeFeedTitleContainerMaxHeight,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  decoration: const BoxDecoration(
                                                    color: ConstantsV2.lightGrey,
                                                  ),
                                                  //sections header
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Novedades${prefs.getBool(isFamily) ??
                                                              false ? " de " : ''}',
                                                          style: boldoSubTextStyle.copyWith(
                                                              color: ConstantsV2.inactiveText),
                                                        ),
                                                        prefs.getBool(isFamily) ?? false
                                                            ? Text(
                                                            '${patient
                                                                .relationshipDisplaySpan}',
                                                            style: boldoSubTextStyle
                                                                .copyWith(
                                                                color:
                                                                ConstantsV2.green))
                                                            : Container(),
                                                      ],
                                                    ),
                                                  )),
                                            );
                                          } else {
                                            return Text(
                                              'Novedades',
                                              style: boldoSubTextStyle.copyWith(
                                                  color: ConstantsV2.inactiveText),
                                            );
                                          }
                                        }else{
                                          return Container();
                                        }
                                      }
                                  );
                                }else{
                                  return Container();
                                }
                              }else {
                                // fill the height between carousel and tabview
                                // with container with lightGrey color
                                return Container(
                                    width: double.maxFinite,
                                    height: ConstantsV2.homeFeedTitleContainerMinHeight,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: const BoxDecoration(
                                    color: ConstantsV2.lightGrey,
                                  ),
                                );
                              }
                            },
                          ),
                        ]);
                      }),
                    );
                  },
                ),
              ],
              body: BlocBuilder<HomeOrganizationBloc,HomeOrganizationBlocState>(
                builder: (context, state){
                  if(state is OrganizationsObtained) {
                    if (BlocProvider.of<patientBloc.PatientBloc>(context)
                        .getOrganizations().isNotEmpty){
                      return TabBarView(
                        controller: _controller,
                        children: [
                          _buildNews(),
                        ],
                      );
                    }else{
                      return _emptyOrganizations();
                    }
                  }else if(state is HomeOrganizationFailed){
                    return Container(
                        child: DataFetchErrorWidget(retryCallback: () => BlocProvider.of<HomeOrganizationBloc>(context).add(GetOrganizationsSubscribed()) ) );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Constants.primaryColor400),
                        backgroundColor: Constants.primaryColor600,
                      ),
                    );
                  }
                },
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, int carouselIndex) {
    return CustomCardPage(
      carouselCard: items[carouselIndex],
      height: _heightCarouselCard,
      width: _widthCarouselCard,
      radius: _radiusCarouselCard,
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
                    picture: "empty_news.svg",
                    titleBottom: "Aún no hay novedades",
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

  Widget _emptyOrganizations(){
    return Container(
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const MaterialClassicHeader(
          color: Constants.primaryColor800,
        ),
        controller: _refreshControllerOrganizationsCheck!,
        onLoading: () {
        },
        onRefresh: _onRefreshOrganizationsCheck,
        footer: CustomFooter(
          height: 140,
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Obteniendo Organizaciones",
                  style: TextStyle(
                    color: Constants.primaryColor800,
                  ),
                )
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("¿En dónde vas a consultar?",
                    style: boldoSubTextMediumStyle.copyWith(color: ConstantsV2.activeText),
                  ),
                  Text("Para usar algunos servicios que Boldo tiene para vos, "
                      "es necesario seas miembro de la organización que las provée.",
                      style: boldoCorpMediumTextStyle.copyWith(color: ConstantsV2.activeText)
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (BuildContext context) => Organizations()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text("Agregar"),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icon/empty_org_home.svg')
                    ],
                  )
                ].map(
                      (e) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: e,
                  ),
                ).toList(),
              ),
            ],
          )
        )
      ),
    );
  }

}


class CustomCardPage extends StatefulWidget {
  final CarouselCard carouselCard;
  final double height;
  final double width;
  final double radius;

  const CustomCardPage({
    Key? key,
    required this.carouselCard,
    required this.height,
    required this.width,
    required this.radius,
  }) : super(key: key);

  @override
  State<CustomCardPage> createState() => _CustomCardPageState();
}

class _CustomCardPageState extends State<CustomCardPage> {

  @override
  Widget build(BuildContext context) {

    // indicates if the patient needs to belong to an organization to access this module
    bool enable = widget.carouselCard.requiredOrganization ?
      BlocProvider.of<patientBloc.PatientBloc>(context)
        .getOrganizations().isNotEmpty : true;

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
          onTap: widget.carouselCard.appear && enable
              ? () {
                  if(widget.carouselCard.page != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => widget.carouselCard.page!));
                  }
                  else if(widget.carouselCard.pageRoute != null) {
                    Navigator.pushNamed(
                        context,
                        '${widget.carouselCard.pageRoute!}');
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
                      colorFilter: widget.carouselCard.appear && enable
                          ? null
                          : const ColorFilter.mode(
                                  Colors.black, BlendMode.hue),
                      image: AssetImage(widget.carouselCard.image),
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
                          widget.carouselCard.appear
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
                                widget.carouselCard.title,
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

class CarouselCard extends StatelessWidget {
  final String image;
  final int index;
  final BoxFit boxFit;
  final Alignment alignment;
  final String title;
  final bool appear;
  final Widget? page;
  final String? pageRoute;
  final bool requiredOrganization;

  const CarouselCard({
    Key? key,
    required this.image,
    required this.boxFit,
    required this.alignment,
    required this.index,
    required this.title,
    required this.appear,
    this.page,
    this.pageRoute,
    this.requiredOrganization = false,
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
