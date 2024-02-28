import 'package:boldo/blocs/goToTop_bloc/goToTop_bloc.dart';
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
import 'package:boldo/screens/dashboard/tabs/components/info_cards_list.dart';
import 'package:boldo/screens/organizations/memberships_screen.dart';
import 'package:boldo/screens/doctor_search/doctors_available.dart';
import 'package:boldo/screens/passport/passport.dart';
import 'package:boldo/screens/prescriptions/prescriptions_screen.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/background.dart';
import 'package:boldo/widgets/go_to_top.dart';
import 'package:boldo/widgets/info_card.dart';
import 'package:boldo/widgets/loading.dart';
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

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  late TabController _controller;
  // controller for scroll
  ScrollController homeScroll = ScrollController();
  // flag for show or not the button
  bool showAnimatedButton = false;

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 3),
    value: 1, // percent initial of height
    vsync: this,
  );

  //percent of elements height to change according of scroll
  double percentOfHeight = 1;

  List<Appointment> appointments = [];
  List<DiagnosticReport> diagnosticReports = [];

  List<News> news = [];

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
      if(homeScroll.offset >=0 &&
          homeScroll.offset <=
              (ConstantsV2.homeAppBarMaxHeight-ConstantsV2.homeAppBarMinHeight )
      ){
        percentOfHeight =( (ConstantsV2.homeAppBarMaxHeight-ConstantsV2.homeAppBarMinHeight )
            - homeScroll.offset ) / (ConstantsV2.homeAppBarMaxHeight-ConstantsV2.homeAppBarMinHeight );
        _animationController.value = percentOfHeight;
        setState(() {
          });
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
    homeScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context){
        return GoToTopBloc();
      },
      child: Scaffold(
        backgroundColor: ConstantsV2.grayLight,
        floatingActionButton: ButtonGoTop(
          scrollController: homeScroll,
          animationDuration: 1000,
          scrollDuration: 500,
          showAnimatedButton: showAnimatedButton,
        ),
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<HomeOrganizationBloc, HomeOrganizationBlocState>(
                listener: (context, state) {
                  if (state is HomeOrganizationFailed) {

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
                    if(state.organizationsList.isNotEmpty) {
                      BlocProvider.of<HomeNewsBloc>(context).add(GetNews());
                    }


                    if (_refreshControllerOrganizationsCheck != null) {
                      _refreshControllerOrganizationsCheck!.refreshCompleted();
                      _refreshControllerOrganizationsCheck!.loadComplete();
                    }
                    BlocProvider.of<HomeBloc>(context).add(ReloadHome());
                  }
                },
              ),
              BlocListener<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is HomeSuccess) {
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
            child: Column(
              children: [
                HomeTabAppBar(
                  controller: _animationController,
                ),
                Expanded(
                  child: BlocBuilder<HomeOrganizationBloc,HomeOrganizationBlocState>(
                  builder: (context, state){
                    if(state is OrganizationsObtained) {
                      if (BlocProvider.of<patientBloc.PatientBloc>(context)
                          .getOrganizations().isNotEmpty){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizeTransition(
                                    sizeFactor: _animationController,
                                    child: DividerFeedSectionHome(
                                      text: "¿Qué desea hacer?",
                                      scale: percentOfHeight,
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children:
                                      items.map((e) => _buildCarousel(context, e)).toList(),
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  SingleChildScrollView(
                                    child: InfoCardList(),
                                  ),
                                ],
                              ),
                            ),
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
                                                            'novedades${prefs.getBool(isFamily) ??
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
                                                'novedades',
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
                            Container(
                              height: 16,
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _controller,
                                children: [
                                  _buildNews(),
                                ],
                              ),
                            ),
                          ],
                        );
                      }else{
                        return _emptyOrganizations();
                      }
                    }else if(state is HomeOrganizationFailed){
                      return Container(
                          child: DataFetchErrorWidget(retryCallback: () => BlocProvider.of<HomeOrganizationBloc>(context).add(GetOrganizationsSubscribed()) ) );
                    } else {
                      return loadingStatus();
                    }
                  },
                ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, CarouselCard carouselItem) {
    return CustomCardPage(
      carouselCard: carouselItem,
      controller: homeScroll,
    );
  }

  Widget _buildNews() {
    return Container(
      child: SmartRefresher(
        physics: const ClampingScrollPhysics(),
        scrollController: homeScroll,
        enablePullDown: true,
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
                ? ListView.separated(
              shrinkWrap: true,
              itemCount: news.length,
              scrollDirection: Axis.vertical,
              itemBuilder: _newsCard,
              physics: const ClampingScrollPhysics(),
              separatorBuilder: (BuildContext context, index){
                return const SizedBox(
                  height: 10,
                );
              },
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
              child: loadingStatus(),
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
                physics: const ClampingScrollPhysics(),
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
  final ScrollController controller;

  const CustomCardPage({
    Key? key,
    required this.carouselCard,
    required this.controller,
  }) : super(key: key);

  @override
  State<CustomCardPage> createState() => _CustomCardPageState();
}

class _CustomCardPageState extends State<CustomCardPage> with TickerProviderStateMixin {

  //percent of elements height to change according of scroll
  double percentOfHeight = 1;

  late ShapeDecoration endDecoration;

  late AnimationController _controller ;

  bool enable = true;

  @override
  void initState(){
    // indicates if the patient needs to belong to an organization to access this module
    enable = widget.carouselCard.requiredOrganization ?
    BlocProvider.of<patientBloc.PatientBloc>(context)
        .getOrganizations().isNotEmpty : true;
    endDecoration = ShapeDecoration(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((100-10)*(1-percentOfHeight)+10),
      ),
      image: DecorationImage(
        fit: BoxFit.cover,
        colorFilter: widget.carouselCard.appear && enable
            ? null
            : const ColorFilter.mode(
            Colors.black, BlendMode.hue),
        image: AssetImage(widget.carouselCard.image),
      ),
    );
    _controller = AnimationController(
      vsync: this,
    );
    widget.controller.addListener(() {
      if(widget.controller.offset >=0 &&
          widget.controller.offset <=
              (ConstantsV2.homeAppBarMaxHeight-ConstantsV2.homeAppBarMinHeight )
      ){
        if(mounted)
        setState(() {
          percentOfHeight =( (ConstantsV2.homeAppBarMaxHeight-ConstantsV2.homeAppBarMinHeight )
              - widget.controller.offset ) / (ConstantsV2.homeAppBarMaxHeight-ConstantsV2.homeAppBarMinHeight );
          endDecoration = ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((100-10)*(1-percentOfHeight)+10),
            ),
            image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: widget.carouselCard.appear && enable
                  ? null
                  : const ColorFilter.mode(
                  Colors.black, BlendMode.hue),
              image: AssetImage(widget.carouselCard.image),
            ),
          );
          _controller.value = 1-percentOfHeight;
        });
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return TweenAnimationBuilder(
      tween: DecorationTween(
        begin: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((100-10)*(1-percentOfHeight)+10),
          ),
          image: DecorationImage(
            fit: BoxFit.cover,
            colorFilter: widget.carouselCard.appear && enable
                ? null
                : const ColorFilter.mode(
                Colors.black, BlendMode.hue),
            image: AssetImage(widget.carouselCard.image),
          ),
        ),
        end: endDecoration,
      ),
      duration: Duration.zero,
      builder: (_, Decoration boxDecoration, __){
        return InkWell(
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
            clipBehavior: Clip.hardEdge,
            height: 50+(130-50)*percentOfHeight,
            width: 50+(110-50)*percentOfHeight,
            margin: const EdgeInsets.all(6),
            decoration: boxDecoration,
            child: BackgroundLinearGradientTransition(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              initialColors: [
                Colors.black,
                Colors.black.withOpacity(0.01),
              ],
              finalColors: [
                Colors.transparent,
                Colors.transparent,
              ],
              initialStops: [
                -.0159,
                0.9034,
              ],
              finalStops: [
                -.0159,
                0.9034,
              ],
              animationController: _controller,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.carouselCard.appear
                          ? const Text("")
                          : AnimatedOpacity(
                        opacity: (percentOfHeight),
                        duration: const Duration(milliseconds: 1),
                        child: (1-percentOfHeight) < .70
                            ? CardNotAvailable()
                            : null,
                      ),
                      Flexible(
                        child: AnimatedOpacity(
                          opacity: (percentOfHeight),
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            widget.carouselCard.title,
                            style: boldoCorpMediumBlackTextStyle,
                          ),
                        ),
                      ),
                    ]),
              )
            )
          )
        );
      },
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
