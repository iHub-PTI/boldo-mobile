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
  int offsetFavoriteDoctors = 0;

  int maxSizeFavoriteDoctors = 0;
  int maxSizeAllDoctors = 0;

  //controllers for smartRefresh to pull and get more doctors
  final RefreshController _refreshDoctorController = RefreshController();

  final RefreshController _refreshFavoriteDoctorController =
      RefreshController();

  // scroll controller
  ScrollController scrollDoctorList = ScrollController();
  List<Doctor>? doctorsSaved;

  final GlobalKey<AnimatedGridState> gridFavoriteDoctorsKey =
      GlobalKey<AnimatedGridState>();

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
    _refreshFavoriteDoctorController.dispose();
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
                    offsetFavoriteDoctors = 0;
                    setState(() {
                      doctors = state.doctors.items ?? [];
                    });
                    getRecentDoctors();
                    getFavoriteDoctors();
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
              BlocListener<FavoriteDoctorsBloc, FavoriteDoctorsState>(
                listener: (context, state) {
                  if (state is FavoriteDoctorsLoaded) {
                    _refreshFavoriteDoctorController
                      ..refreshCompleted()
                      ..loadComplete();
                    favoritesDoctors.clear();
                    maxSizeFavoriteDoctors = state.doctors.total ?? 0;

                    state.doctors.items?.removeWhere(
                      (newDoctor) => favoritesDoctors
                          .any((doctor) => newDoctor.id == doctor.id),
                    );

                    state.doctors.items?.forEach((doctor) {
                      favoritesDoctors.add(doctor);
                      try {
                        gridFavoriteDoctorsKey.currentState!.insertItem(
                          favoritesDoctors.length - 1,
                          duration: durationFavoriteAction,
                        );
                      } catch (error) {
                        //none
                      }
                    });
                  } else if (state is MoreFavoriteDoctorsLoaded) {
                    _refreshFavoriteDoctorController
                      ..refreshCompleted()
                      ..loadComplete();
                    maxSizeFavoriteDoctors = state.doctors.total ?? 0;

                    state.doctors.items?.removeWhere(
                      (newDoctor) => favoritesDoctors
                          .any((doctor) => newDoctor.id == doctor.id),
                    );

                    state.doctors.items?.forEach((doctor) {
                      favoritesDoctors.add(doctor);
                      try {
                        gridFavoriteDoctorsKey.currentState!.insertItem(
                          favoritesDoctors.length - 1,
                          duration: durationFavoriteAction,
                        );
                      } catch (error) {
                        //none
                      }
                    });
                    // reloadScreen
                    setState(() {});
                  } else if (state is FailedFavoriteDoctors) {
                    _refreshFavoriteDoctorController
                      ..refreshCompleted()
                      ..loadComplete();
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: SmartRefresher(
        physics: const ClampingScrollPhysics(),
        controller: _refreshFavoriteDoctorController,
        enablePullUp: favoritesDoctors.length < maxSizeFavoriteDoctors,
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
          offsetFavoriteDoctors = 0;
          getFavoriteDoctors();
        },
        // this for load more doctors
        onLoading: () {
          offsetFavoriteDoctors =
              offsetFavoriteDoctors + appConfig.ALL_DOCTORS_PAGE_COUNT;
          getMoreFavoriteDoctors();
        },
        child: _favoritesDoctors(),
      ),
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

  Widget _emptyFavoriteDoctors() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Center(
              child: SvgPicture.asset(
                'assets/icon/empty_favorite_doctors.svg',
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              const Text(
                'No hay favoritos',
                style: TextStyle(
                  color: ConstantsV2.activeText,
                  fontStyle: FontStyle.normal,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Tu listado de médicos aparecerá aquí una vez marcado como favorito',
                style: bodyMediumRegular.copyWith(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _emptyRecentDoctors() {
    return Container(
      color: ConstantsV2.grayLightest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 39),
        child: Column(
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/icon/empty_recentDoctors.svg',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                const Text(
                  'No hay consultas recientes',
                  style: TextStyle(
                    color: ConstantsV2.activeText,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'El listado aparecerá aquí una vez que hayas consultado',
                  style: bodyMediumRegular.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentDoctors() {
    return BlocBuilder<RecentDoctorsBloc, RecentDoctorsState>(
      builder: (context, state) {
        if (state is LoadingRecentDoctors) {
          return loadingStatus();
        } else if (state is FailedRecentDoctors) {
          return DataFetchErrorWidget(
            retryCallback: () {
              getRecentDoctors();
            },
          );
        } else {
          return recentDoctors.isNotEmpty
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ConstantsV2.grayLightest,
                          boxShadow: [
                            shadowRegular,
                          ],
                        ),
                        height: 250,
                        child: GridView.builder(
                          physics: const ScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            childAspectRatio: 4 / 3.2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: recentDoctors.length,
                          itemBuilder: (context, index) {
                            return DoctorBoxWidget(
                              doctor: recentDoctors[index],
                              onSuccessFavoriteAction: () {
                                updateFavoriteStatus(
                                  doctor: recentDoctors[index],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : _emptyRecentDoctors();
        }
      },
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

  Widget _favoritesDoctors() {
    return BlocBuilder<FavoriteDoctorsBloc, FavoriteDoctorsState>(
      builder: (context, state) {
        if (state is LoadingFavoriteDoctors) {
          return loadingStatus();
        } else if (state is FailedFavoriteDoctors) {
          return DataFetchErrorWidget(
            retryCallback: () {
              getFavoriteDoctors();
            },
          );
        } else {
          return favoritesDoctors.isNotEmpty
              ? AnimatedGrid(
                  key: gridFavoriteDoctorsKey,
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 5 / 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  initialItemCount: favoritesDoctors.length,
                  itemBuilder: (context, index, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: DoctorBoxWidget(
                        doctor: favoritesDoctors[index],
                        onSuccessFavoriteAction: () {
                          updateFavoriteStatus(
                            doctor: favoritesDoctors[index],
                          );
                        },
                      ),
                    );
                  },
                )
              : _emptyFavoriteDoctors();
        }
      },
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

  void getRecentDoctors() {
    BlocProvider.of<RecentDoctorsBloc>(context).add(
      GetRecentDoctors(
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

  void getFavoriteDoctors() {
    BlocProvider.of<FavoriteDoctorsBloc>(context).add(
      GetFavoriteDoctors(
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

  void getMoreFavoriteDoctors() {
    BlocProvider.of<FavoriteDoctorsBloc>(context).add(
      GetMoreFavoriteDoctors(
        organizations: Provider.of<DoctorFilterProvider>(context, listen: false)
            .getOrganizationsApplied,
        offset: offsetFavoriteDoctors,
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
    final doctorAction = Doctor.fromJson(doctor.toJson());
    if (!doctorAction.isFavorite) {
      doctorAction.isFavorite = true;
      favoritesDoctors.add(doctorAction);
      try {
        gridFavoriteDoctorsKey.currentState?.insertItem(
          favoritesDoctors.length - 1,
          duration: durationFavoriteAction,
        );
      } catch (error) {
        //none
      }
    } else {
      try {
        final index = favoritesDoctors.lastIndexWhere(
          (element) => element.id == doctorAction.id,
        );

        favoritesDoctors.removeAt(index);
        gridFavoriteDoctorsKey.currentState!.removeItem(
          index,
          (context, animation) => FadeTransition(
            opacity: animation,
            child: DoctorBoxWidget(
              doctor: doctorAction,
              onSuccessFavoriteAction: () {
                updateFavoriteStatus(
                  doctor: doctorAction,
                );
              },
            ),
          ),
          duration: durationFavoriteAction,
        );
      } catch (error) {
        //none
      }
    }

    // update all list of doctors because the doctor instanced is distinct
    // in every list

    // update favorite status in list of all doctors
    for (final element in doctors) {
      if (element.id == doctorAction.id) {
        element.isFavorite = !element.isFavorite;
      }
    }

    // update favorite status in list of recent doctors
    for (final element in recentDoctors) {
      if (element.id == doctorAction.id) {
        element.isFavorite = !element.isFavorite;
      }
    }
    // update view
    setState(() {});
  }
}
