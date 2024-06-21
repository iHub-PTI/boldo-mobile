import 'package:boldo/app_config.dart';
import 'package:boldo/blocs/goToTop_bloc/goToTop_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/features/doctor_search/doctor_search.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/go_to_top.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// List of doctors available in patient common organization
class DoctorsAvailable extends StatefulWidget {
  /// constructor
  const DoctorsAvailable({
    required this.callFromHome,
    super.key,
    this.doctors,
  });

  /// flag for trigger the GetDoctorsAvailable event
  final bool callFromHome;

  /// if callFromHome is True this parameter can be null
  final List<Doctor>? doctors;
  @override
  _DoctorsAvailableState createState() => _DoctorsAvailableState();
}

// STATE CLASS
class _DoctorsAvailableState extends State<DoctorsAvailable>
    with SingleTickerProviderStateMixin {
  // filter provider
  late DoctorFilterProvider _myProvider;

  //list of doctors for tabs
  List<Doctor> doctors = [];
  List<Doctor> recentDoctors = [];
  List<Doctor> favoritesDoctors = [];

  // initial value
  int offsetAllDoctors = 0;

  int maxSizeAllDoctors = 0;

  //controllers for smartRefresh to pull and get more doctors
  final RefreshController _refreshDoctorController = RefreshController();

  // scroll controller
  ScrollController scrollDoctorList = ScrollController();

  final Duration durationFavoriteAction = const Duration(seconds: 1);

  late TabController _tabController;

  @override
  void initState() {
    _myProvider = Provider.of<DoctorFilterProvider>(context, listen: false);
    getDoctors();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    _myProvider.clearFilter();
    _refreshDoctorController.dispose();
    _tabController.dispose();
    scrollDoctorList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return GoToTopBloc();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: const [],
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SvgPicture.asset(
              'assets/Logo.svg',
              semanticsLabel: 'BOLDO Logo',
            ),
          ),
        ),
        floatingActionButton: ButtonGoTop(
          scrollController: scrollDoctorList,
          animationDuration: 1000,
          scrollDuration: 500,
        ),
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<DoctorsAvailableBloc, DoctorsAvailableState>(
                listener: (context, state) {
                  if (state is DoctorsLoaded) {
                    maxSizeAllDoctors = state.doctors.total ?? 0;
                    offsetAllDoctors = 0;
                    setState(() {
                      doctors = state.doctors.items ?? [];
                    });
                  } else if (state is MoreDoctorsLoaded) {
                    if (mounted) {
                      _refreshDoctorController
                        ..refreshCompleted()
                        ..loadComplete();
                      maxSizeAllDoctors = state.doctors.total ?? 0;

                      state.doctors.items?.removeWhere(
                        (newDoctor) =>
                            doctors.any((doctor) => newDoctor.id == doctor.id),
                      );

                      setState(() {
                        doctors = [...doctors, ...state.doctors.items ?? []];
                      });
                    }
                  } else if (state is Failed) {
                    _refreshDoctorController
                      ..refreshCompleted()
                      ..loadComplete();
                  }
                },
              ),
              BlocListener<RecentDoctorsBloc, RecentDoctorsState>(
                listener: (context, state) {
                  if (state is RecentDoctorsLoaded) {
                    setState(() {
                      recentDoctors = state.doctors;
                    });
                  }
                },
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ConstantsV2.lightAndClear,
                    boxShadow: [
                      shadowHeader,
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButtonLabel(
                        labelText: 'Médicos',
                        padding: null,
                      ),
                      Row(
                        children: [
                          ImageViewTypeForm(
                            height: 44,
                            width: 44,
                            url: patient.photoUrl,
                            gender: patient.gender,
                            border: true,
                            borderColor: ConstantsV2.secondaryRegular,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DoctorFilterScreen(
                                    fromResult: false,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: ConstantsV2.secondaryRegular,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: buttonFXSecondaryStyle.copyWith(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: SvgPicture.asset(
                                  'assets/icon/search.svg',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                BlocBuilder<DoctorsAvailableBloc, DoctorsAvailableState>(
                  builder: (context, state) {
                    if (state is Loading || state is Failed) {
                      return loadingStatus();
                    } else if (state is Failed) {
                      return DataFetchErrorWidget(
                        retryCallback: () {
                          getDoctors();
                        },
                      );
                    } else {
                      return doctors.isNotEmpty ? _body() : _emptyDoctor();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return Expanded(
      child: NestedScrollView(
        controller: scrollDoctorList,
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              forceElevated: innerBoxIsScrolled,
              pinned: true,
              flexibleSpace: _tabBar(),
            ),
          ];
        },
        body: _tabs(),
      ),
    );
  }

  Widget _tabs() {
    return TabBarView(
      physics: const ClampingScrollPhysics(),
      controller: _tabController,
      children: [
        _recentDoctorTab(),
        _favoriteDoctorTab(),
      ],
    );
  }

  Widget _tabBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: ConstantsV2.grayLightest,
      child: Stack(
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/decorations/line_separator.svg',
            ),
          ),
          TabBar(
            labelStyle: boldoTabHeaderSelectedTextStyle,
            unselectedLabelStyle: boldoTabHeaderUnselectedTextStyle,
            indicatorColor: Colors.transparent,
            unselectedLabelColor: const Color.fromRGBO(119, 119, 119, 1),
            labelColor: ConstantsV2.activeText,
            controller: _tabController,
            tabs: const [
              Text(
                'Recientes',
              ),
              Text(
                'Favoritos',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentDoctorTab() {
    return SmartRefresher(
      physics: const ClampingScrollPhysics(),
      controller: _refreshDoctorController,
      enablePullUp: doctors.length < maxSizeAllDoctors,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body = const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_upward,
                color: Constants.extraColor300,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Sube para cargar más',
                style: TextStyle(
                  color: Constants.extraColor300,
                ),
              ),
            ],
          );
          if (mode == LoadStatus.loading) {
            body = loadingStatus();
          }
          return Center(child: body);
        },
      ),
      // this for refresh all data
      onRefresh: () {
        offsetAllDoctors = 0;
        getDoctors();
      },
      // this for load more doctors
      onLoading: () {
        offsetAllDoctors = offsetAllDoctors + appConfig.ALL_DOCTORS_PAGE_COUNT;
        getMoreDoctors();
      },
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          const SizedBox(
            height: 16,
          ),
          _recentDoctors(),
          const SizedBox(
            height: 24,
          ),
          _allDoctors(),
        ],
      ),
    );
  }

  Widget _favoriteDoctorTab() {
    return DoctorsFavoriteWidget(
      doctors: favoritesDoctors,
      updateFavoriteStatus: updateFavoriteStatus,
    );
  }

  Widget _emptyDoctor() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Center(
              child: SvgPicture.asset(
                'assets/icon/empty-doctors.svg',
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              Text(
                'A medida que vayas usando la app, vas a ver algunas '
                'sugerencias de médicos en esta sección.',
                style: bodyMediumRegular.copyWith(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'De momento, podés hacer una búsqueda entre los médicos a '
                'los que tenés acceso.',
                style: bodyMediumRegular.copyWith(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorFilterScreen(
                      fromResult: false,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: ConstantsV2.secondaryRegular,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 18,
                      ),
                      decoration: buttonFXSecondaryStyle.copyWith(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Buscar',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: ConstantsV2.grayLightest,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SvgPicture.asset(
                            'assets/icon/search.svg',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentDoctors() {
    return DoctorsRecentWidget(
      doctors: recentDoctors,
      updateFavoriteStatus: updateFavoriteStatus,
    );
  }

  Widget _allDoctors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Text(
            'Todos los médicos',
            style: boldoScreenSubtitleTextStyle.copyWith(
              color: ConstantsV2.activeText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ConstantsV2.grayLightest,
            boxShadow: [
              shadowRegular,
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: DoctorsGridWidget(
            doctors: doctors,
            updateFavoriteStatus: updateFavoriteStatus,
          ),
        ),
      ],
    );
  }

  void getDoctors() {
    BlocProvider.of<DoctorsAvailableBloc>(context).add(
      GetDoctorFilter(
        organizations: Provider.of<DoctorFilterProvider>(context, listen: false)
            .getOrganizationsApplied,
        specializations:
            Provider.of<DoctorFilterProvider>(context, listen: false)
                .getSpecializationsApplied,
        virtualAppointment:
            Provider.of<DoctorFilterProvider>(context, listen: false)
                .getLastVirtualAppointmentApplied,
        inPersonAppointment:
            Provider.of<DoctorFilterProvider>(context, listen: false)
                .getLastInPersonAppointmentApplied,
        names: Provider.of<DoctorFilterProvider>(context, listen: false)
            .getNamesApplied,
      ),
    );
  }

  void getMoreDoctors() {
    BlocProvider.of<DoctorsAvailableBloc>(context).add(
      GetMoreFilterDoctor(
        organizations: Provider.of<DoctorFilterProvider>(context, listen: false)
            .getOrganizationsApplied,
        offset: offsetAllDoctors,
        specializations:
            Provider.of<DoctorFilterProvider>(context, listen: false)
                .getSpecializationsApplied,
        virtualAppointment:
            Provider.of<DoctorFilterProvider>(context, listen: false)
                .getLastVirtualAppointmentApplied,
        inPersonAppointment:
            Provider.of<DoctorFilterProvider>(context, listen: false)
                .getLastInPersonAppointmentApplied,
        names: Provider.of<DoctorFilterProvider>(context, listen: false)
            .getNamesApplied,
      ),
    );
  }

  void updateFavoriteStatus({required Doctor doctor}) {
    BlocProvider.of<FavoriteDoctorsBloc>(context).add(
      SetFavoriteLocalDoctor(
        doctor: doctor,
      ),
    );
  }
}
