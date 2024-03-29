import 'package:boldo/app_config.dart';
import 'package:boldo/blocs/doctors_available_bloc/doctors_available_bloc.dart';
import 'package:boldo/blocs/doctors_favorite_bloc/doctors_favorite_bloc.dart';
import 'package:boldo/blocs/doctors_recent_bloc/doctors_recent_bloc.dart';
import 'package:boldo/blocs/favorite_action_bloc/favorite_action_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/doctor_profile/doctor_profile_screen.dart';
import 'package:boldo/screens/doctor_search/doctor_filter.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/go_to_top.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// PRINCIPAL CLASS
class DoctorsAvailable extends StatefulWidget {
  // flag for trigger the GetDoctorsAvailable event
  final bool callFromHome;
  // if callFromHome is True this parameter can be null
  final List<Doctor>? doctors;
  DoctorsAvailable({required this.callFromHome, this.doctors});
  @override
  _DoctorsAvailableState createState() => _DoctorsAvailableState();
}

// STATE CLASS
class _DoctorsAvailableState extends State<DoctorsAvailable> with SingleTickerProviderStateMixin{

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
  RefreshController _refreshDoctorController =
      RefreshController(initialRefresh: false);

  RefreshController _refreshFavoriteDoctorController =
  RefreshController(initialRefresh: false);


  // scroll controller
  ScrollController scrollDoctorList = ScrollController();
  // flag for show or not the scroll button
  bool showAnimatedButton = false;
  List<Doctor>? doctorsSaved;

  final GlobalKey<AnimatedGridState> gridFavoriteDoctorsKey = GlobalKey<AnimatedGridState>();

  final Duration durationFavoriteAction = const Duration(seconds: 1);

  late TabController _tabController;

  @override
  void initState() {
    _myProvider = Provider.of<DoctorFilterProvider>(context, listen: false);
    getDoctors();
    scrollDoctorList.addListener(() {
    double offset = 10.0; // or the value you want
    if (scrollDoctorList.offset > offset){
      showAnimatedButton = true;
      // this we use to get update the state
      setState((){

      });
    } else {
      showAnimatedButton = false;
      setState((){

      });
    }
  });

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
      floatingActionButton: buttonGoTop(scrollDoctorList, 1000, 500, showAnimatedButton),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<DoctorsAvailableBloc, DoctorsAvailableState>(
              listener: (context, state) {
                if (state is DoctorsLoaded) {
                  maxSizeAllDoctors = state.doctors.total??0;
                  setState(() {
                    doctors = state.doctors.items?? [];
                  });
                  getRecentDoctors();
                  getFavoriteDoctors();
                } else if (state is MoreDoctorsLoaded) {
                  if (mounted) {
                    _refreshDoctorController.refreshCompleted();
                    _refreshDoctorController.loadComplete();
                    maxSizeAllDoctors = state.doctors.total??0;

                    state.doctors.items?.removeWhere(
                      (newDoctor) => doctors.any(
                        (doctor) => newDoctor.id == doctor.id
                      )
                    );

                    setState(() {
                      doctors = [...doctors, ...state.doctors.items?? [] ];
                    });
                  }
                } else if (state is FilterLoadedInDoctorList) {
                  _refreshDoctorController.refreshCompleted();
                  _refreshDoctorController.loadComplete();
                  maxSizeAllDoctors = state.doctors.total??0;
                  setState(() {
                    doctors = state.doctors.items?? [];
                  });
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
                  _refreshFavoriteDoctorController.refreshCompleted();
                  _refreshFavoriteDoctorController.loadComplete();
                  favoritesDoctors.clear();
                  maxSizeFavoriteDoctors = state.doctors.total??0;

                  state.doctors.items?.removeWhere(
                          (newDoctor) => favoritesDoctors.any(
                              (doctor) => newDoctor.id == doctor.id
                      )
                  );

                  state.doctors.items?.forEach((doctor) {
                    favoritesDoctors.add(doctor);
                    try {
                      gridFavoriteDoctorsKey.currentState!.insertItem(
                        favoritesDoctors.length - 1,
                        duration: durationFavoriteAction
                      );
                    } catch (error) {
                      //none
                    }
                  });
                }else if (state is MoreFavoriteDoctorsLoaded) {
                  _refreshFavoriteDoctorController.refreshCompleted();
                  _refreshFavoriteDoctorController.loadComplete();
                  maxSizeFavoriteDoctors = state.doctors.total??0;

                  state.doctors.items?.removeWhere(
                          (newDoctor) => favoritesDoctors.any(
                              (doctor) => newDoctor.id == doctor.id
                      )
                  );

                  state.doctors.items?.forEach((doctor) {
                    favoritesDoctors.add(doctor);
                    try {
                      gridFavoriteDoctorsKey.currentState!.insertItem(
                        favoritesDoctors.length - 1,
                        duration: durationFavoriteAction
                      );
                    } catch (error) {
                      //none
                    }
                  });
                  // reloadScreen
                  setState(() {

                  });
                }else if (state is FailedFavoriteDoctors){
                  _refreshFavoriteDoctorController.refreshCompleted();
                  _refreshFavoriteDoctorController.loadComplete();
                }
              },
            ),
          ],
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: ConstantsV2.lightAndClear,
                    boxShadow: [
                      shadowHeader,
                    ]
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButtonLabel(labelText: 'Médicos',padding: null,),
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
                                  builder: (context) => DoctorFilter(),
                                ),
                              );
                            },
                            child:Card(
                              color: ConstantsV2.secondaryRegular,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(100)),
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
                  builder: (context, state){
                    if(state is Loading || state is FilterLoading)
                      return const Center(child: CircularProgressIndicator());
                    else if(state is Failed){
                      return DataFetchErrorWidget(
                          retryCallback: (){ getDoctors(); }
                        );
                      }else{
                        return
                          doctors.isNotEmpty
                              ? _body()
                              : _emptyDoctor();
                      }
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(){
    return Expanded(
      child: NestedScrollView(
        controller: scrollDoctorList,
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _tabBar(),
            ),
          ];
        },
        body: _tabs(),
      ),
    );
  }

  Widget _tabs(){
    return TabBarView(
      physics: const ClampingScrollPhysics(),
      controller: _tabController,
      children: [
        _recentDoctorTab(),
        _favoriteDoctorTab(),
      ],
    );
  }

  Widget _tabBar(){
    return Container(
      padding: const EdgeInsets.all(12),
      color: ConstantsV2.grayLightest,
      child: TabBar(
        labelStyle: boldoTabHeaderSelectedTextStyle,
        unselectedLabelStyle: boldoTabHeaderUnselectedTextStyle,
        indicatorColor: Colors.transparent,
        unselectedLabelColor:
        const Color.fromRGBO(119, 119, 119, 1),
        labelColor: ConstantsV2.activeText,
        controller: _tabController,
        tabs: [
          const Text(
            'Recientes',
          ),
          const Text(
            'Favoritos',
          ),
        ],
      ),
    );
  }

  Widget _recentDoctorTab(){
    return Container(
      //color: ConstantsV2.grayLightest,
      child: SmartRefresher(
        physics: const ClampingScrollPhysics(),
        controller: _refreshDoctorController,
        enablePullUp: doctors.length< maxSizeAllDoctors,
        enablePullDown: true,
        header: const MaterialClassicHeader(
          color: Constants.primaryColor800,
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            _recentDoctors(),
            const SizedBox(height: 24,),
            _allDoctors(),
          ],
        ),
        footer: CustomFooter(
          builder:
              (BuildContext context, LoadStatus? mode) {
            Widget body = Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_upward,
                  color: Constants.extraColor300,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "Sube para cargar más",
                  style: TextStyle(
                    color: Constants.extraColor300,
                  ),
                )
              ],
            );
            if (mode == LoadStatus.loading) {
              body = const CircularProgressIndicator();
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
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
      ),
    );
  }

  Widget _favoriteDoctorTab(){
    return Container(
      color: ConstantsV2.grayLightest,
      child: SmartRefresher(
        physics: const ClampingScrollPhysics(),
        controller: _refreshFavoriteDoctorController,
        enablePullUp: favoritesDoctors.length< maxSizeFavoriteDoctors,
        enablePullDown: true,
        header: const MaterialClassicHeader(
          color: Constants.primaryColor800,
        ),
        child: _favoritesDoctors(),
        footer: CustomFooter(
          builder:
              (BuildContext context, LoadStatus? mode) {
            Widget body = Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_upward,
                  color: Constants.extraColor300,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "Sube para cargar más",
                  style: TextStyle(
                    color: Constants.extraColor300,
                  ),
                )
              ],
            );
            if (mode == LoadStatus.loading) {
              body = const CircularProgressIndicator();
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        // this for refresh all data
        onRefresh: () {
          offsetFavoriteDoctors = 0;
          getFavoriteDoctors();
        },
        // this for load more doctors
        onLoading: () {
          offsetFavoriteDoctors = offsetFavoriteDoctors + appConfig.ALL_DOCTORS_PAGE_COUNT;
          getMoreFavoriteDoctors();
        },
      ),
    );
  }

  Widget _emptyDoctor(){
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
          Container(
            child: Column(
              children: [
                Container(
                  child: Text(
                    "A medida que vayas usando la app, vas a ver algunas "
                        "sugerencias de médicos en esta sección.",
                    style: bodyMediumRegular.copyWith(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: Text(
                      "De momento, podés hacer una búsqueda entre los médicos a "
                          "los que tenés acceso.",
                    style: bodyMediumRegular.copyWith(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
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
                    builder: (context) => DoctorFilter(),
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
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                        decoration: buttonFXSecondaryStyle.copyWith(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Buscar",
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
                        )
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

  Widget _emptyFavoriteDoctors(){
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
          Container(
            child: Column(
              children: [
                Container(
                  child: const Text(
                    "No hay favoritos",
                    style: TextStyle(
                      color: ConstantsV2.activeText,
                      fontStyle: FontStyle.normal,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: Text(
                    "Tu listado de médicos aparecerá aquí una vez marcado como favorito",
                    style: bodyMediumRegular.copyWith(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _emptyRecentDoctors(){
    return Container(
      color: ConstantsV2.grayLightest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 39),
        child: Column(
          children: [
            Container(
              child: Center(
                child: SvgPicture.asset(
                  'assets/icon/empty_recentDoctors.svg',
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    child: const Text(
                      "No hay consultas recientes",
                      style: TextStyle(
                        color: ConstantsV2.activeText,
                        fontStyle: FontStyle.normal,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      "El listado aparecerá aquí una vez que hayas consultado",
                      style: bodyMediumRegular.copyWith(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _recentDoctors(){
    return BlocBuilder<RecentDoctorsBloc, RecentDoctorsState>(
        builder: (context, state){
          if(state is LoadingRecentDoctors)
            return const Center(child: CircularProgressIndicator());
          else if(state is FailedRecentDoctors){
            return DataFetchErrorWidget(
                retryCallback: () { getRecentDoctors(); }
            );
          }else{
            return
              recentDoctors.isNotEmpty? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: ConstantsV2.grayLightest,
                    height: 250,
                    child: GridView.builder(
                      padding:
                      const EdgeInsets.only(right: 16, left: 16),
                      physics: const ScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          childAspectRatio: 4 / 3.2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20),
                      itemCount: recentDoctors.length,
                      itemBuilder: (context, index){
                        return doctorItem(context, recentDoctors[index]);
                      },
                    ),
                  ),
                ],
              ): _emptyRecentDoctors();
          }
        }
    );
  }

  Widget _allDoctors(){
    return ListView(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Text(
            "Todos los médicos",
            style: boldoScreenSubtitleTextStyle.copyWith(
                color: ConstantsV2.activeText
            ),
          ),
        ),
        Container(
          color: ConstantsV2.grayLightest,
          padding:
          const EdgeInsets.only(right: 16, left: 16),
          child: ReorderableBuilder(
            enableDraggable: false,
            children: doctors.map((e) => doctorItem(context, e)).toList(),
            onReorder: _handleReorder,
            enableScrollingWhileDragging: false,
            builder: (children){
              return GridView.builder(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 5 / 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                itemCount: children.length,
                itemBuilder: (context, index){
                  return children[index];
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _favoritesDoctors(){
    return BlocBuilder<FavoriteDoctorsBloc, FavoriteDoctorsState>(
        builder: (context, state){
          if(state is LoadingFavoriteDoctors)
            return const Center(child: CircularProgressIndicator());
          else if(state is FailedFavoriteDoctors){
            return DataFetchErrorWidget(
                retryCallback: () { getFavoriteDoctors(); }
            );
          }else{
            return
              favoritesDoctors.isNotEmpty
                  ? AnimatedGrid(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                key: gridFavoriteDoctorsKey,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 5 / 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                initialItemCount: favoritesDoctors.length,
                itemBuilder: (context, index, animation){
                  return FadeTransition(
                    opacity: animation,
                    child: doctorItem(context, favoritesDoctors[index]),
                  );
                },
              )
                  : _emptyFavoriteDoctors();
          }
        }
    );
  }

  void _handleReorder(List<OrderUpdateEntity> onReorderList) {
    for (final reorder in onReorderList) {
      final child = doctors.removeAt(reorder.oldIndex);
      doctors.insert(reorder.newIndex, child);
    }
    setState(() {});
  }

  Widget _availabilityHourCard(OrganizationWithAvailability? organization){


    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    availableText(organization?.nextAvailability),
                    style: boldoBodySRegularTextStyle
                        .copyWith(
                      color: ConstantsV2
                          .grayLight,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    "vía ${organization?.organization?.name?? 'Desconocido'}",
                    style: boldoBodySRegularTextStyle
                        .copyWith(
                      color: ConstantsV2
                          .grayLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if( organization?.nextAvailability?.availability != null ) Card(
            elevation: 0.0,
            color: ConstantsV2.grayLightAndClear,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: ConstantsV2.grayLightAndClear, width: 1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Text("${DateFormat('HH:mm').format(DateTime.parse(organization?.nextAvailability?.availability?? DateTime.now().toString()).toLocal())}",
                    style: boldoBodySBlackTextStyle.copyWith(color: ConstantsV2.secondaryRegular),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String availableText(NextAvailability? nextAvailability) {
    String available = 'Sin disponibilidad en los próximos 30 días';
    if(nextAvailability == null)
      return available;
    bool isToday = false;
    final today = DateTime.now();
    final parsedAvailability =
        DateTime.parse(nextAvailability.availability!).toLocal();
    int daysDifference = daysBetween(today, parsedAvailability);
    if (daysDifference == 0) {
      isToday = true;
    }
    if (isToday) {
      available = 'Disponible hoy a las ';
    } else if (daysDifference > 0) {
      available =
          'Disponible ${DateFormat('EEEE, dd MMMM', const Locale("es", 'ES').languageCode).format(parsedAvailability)} a las';
    }
    return available;
  }

  Widget doctorItem(BuildContext context, Doctor doctor) {
    return GestureDetector(
      key: Key(doctor.id?? '0'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfileScreen(
              doctor: doctor,
              showAvailability: true,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Stack(
          children: <Widget>[
            // the first item in stack is the doctor profile photo
            doctor.photoUrl != null
                ? Positioned.fill(child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: doctor.photoUrl!,
              progressIndicatorBuilder:
                  (context, url, downloadProgress) => Padding(
                padding: const EdgeInsets.all(26.0),
                child: Center(
                  child: CircularProgressIndicator(
                    value: downloadProgress.progress,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(
                        Constants.primaryColor400),
                    backgroundColor: Constants.primaryColor600,
                  ),
                ),
              ),
              errorWidget: (context, url, error) =>
              const Icon(Icons.error),
            ))
                : Positioned.fill(
              child:doctor.gender == 'female'
                  ? SvgPicture.asset(
                'assets/images/femaleDoctor.svg',
                fit: BoxFit.cover,
              )
                  : doctor.gender == 'male'? SvgPicture.asset(
                'assets/images/maleDoctor.svg',
                fit: BoxFit.cover,
              ): SvgPicture.asset(
                'assets/images/persona.svg',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: RadialGradient(
                    radius: 3,
                    center: Alignment.bottomLeft,
                    stops: [
                      0.08,
                      0.72
                    ],
                    colors: [
                      Colors.black,
                      Colors.black.withOpacity(0)
                    ]),
              ),
            ),
            // the second item in stack is the column of details
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      child: favoriteIcon(doctor),
                    ),
                  ],
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // name of the doctor
                        Row(
                          children: [
                            // this for jump if there is overflow
                            Flexible(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 16, bottom: 2),
                                      child: Text(
                                        '${doctor.gender == 'female' ? 'Dra.' : 'Dr.'} ${doctor.givenName!.split(" ")[0]} ${doctor.familyName!.split(" ")[0]}',
                                        style: boldoCardHeadingTextStyle,
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                        // specializations
                        doctor.specializations != null
                            ? doctor.specializations!.length > 0
                            ? Container(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    for (int i = 0;
                                    i <
                                        doctor
                                            .specializations!
                                            .length;
                                    i++)
                                      Text(
                                        "${doctor.specializations![i].description}${doctor.specializations!.length-1 != i  ? ", " : ""}",
                                        style: boldoBodyLRegularTextStyle
                                            .copyWith(
                                          color: ConstantsV2
                                              .buttonPrimaryColor100,
                                        ),
                                      ),
                                  ],
                                ),
                              )),
                        )
                            : Container()
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                          child: _availabilityHourCard(doctor.organizations?.first),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget favoriteIcon(Doctor doctor){
    return BlocProvider<FavoriteActionBloc>(
      create: (BuildContext context) => FavoriteActionBloc(),
      child: BlocBuilder<FavoriteActionBloc, FavoriteActionState>(
        builder: (BuildContext context, state) {
          return BlocListener<FavoriteActionBloc, FavoriteActionState>(
            listener: (context, state) {
              if (state is LoadingFavoriteAction) {
                Doctor doctorAction = Doctor.fromJson(doctor.toJson());
                if(!doctorAction.isFavorite) {
                  doctorAction.isFavorite = true;
                  favoritesDoctors.add(doctorAction);
                  try {
                    gridFavoriteDoctorsKey.currentState!.insertItem(
                      favoritesDoctors.length - 1,
                      duration: durationFavoriteAction,
                    );
                  } catch (error) {
                    //none
                  }
                }else{
                  try {

                    int index = favoritesDoctors.lastIndexWhere(
                        (element) => element.id == doctorAction.id
                    );

                    favoritesDoctors.removeAt(
                        index
                    );
                    gridFavoriteDoctorsKey.currentState!.removeItem(
                      index, (context, animation) => FadeTransition(
                      opacity: animation,
                        child: doctorItem(context, doctorAction),
                      ),
                      duration: durationFavoriteAction,
                    );
                  } catch (error) {
                    //none
                  }
                }


                // update favorite status in list of all doctors
                doctors.forEach((element) {
                  if(element.id == doctorAction.id){
                    element.isFavorite = !element.isFavorite;
                  }
                });

                // update favorite status in list of recent doctors
                recentDoctors.forEach((element) {
                  if(element.id == doctorAction.id){
                    element.isFavorite = !element.isFavorite;
                  }
                });
                // update view
                setState(() {
                });
              }
              if (state is FailedFavoriteAction) {
                emitSnackBar(
                    context: context,
                    text: "No se pudo realizar la acción",
                    status: ActionStatus.Fail
                );
                Doctor doctorAction = Doctor.fromJson(doctor.toJson());
                if(doctorAction.isFavorite) {
                  doctorAction.isFavorite = true;
                  favoritesDoctors.add(doctorAction);
                  try {
                    gridFavoriteDoctorsKey.currentState!.insertItem(
                      favoritesDoctors.length - 1,
                      duration: durationFavoriteAction,
                    );
                  } catch (error) {
                    //none
                  }
                }else{
                  doctorAction.isFavorite = false;
                  try {
                    int index = favoritesDoctors.lastIndexWhere(
                            (element) => element.id == doctorAction.id
                    );

                    favoritesDoctors.removeAt(
                        index
                    );
                    favoritesDoctors.lastWhere((element) => element.id == doctorAction.id);
                    gridFavoriteDoctorsKey.currentState!.removeItem(
                      index, (context, animation) => FadeTransition(
                        opacity: animation,
                        child: doctorItem(context, doctorAction),
                      ),
                      duration: durationFavoriteAction,
                    );
                  } catch (error) {
                    //none
                  }
                }


                // update favorite status in list of all doctors
                doctors.forEach((element) {
                  if(element.id == doctorAction.id){
                    element.isFavorite = !element.isFavorite;
                  }
                });

                // update favorite status in list of recent doctors
                recentDoctors.forEach((element) {
                  if(element.id == doctorAction.id){
                    element.isFavorite = !element.isFavorite;
                  }
                });
                // update view
                setState(() {
                });
              }
            },
            child: GestureDetector(
              onTap: state is LoadingFavoriteAction? () => {}: (){
                BlocProvider.of<FavoriteActionBloc>(context).add(
                    PutFavoriteStatus(
                      doctor: doctor,
                      favoriteStatus: ! doctor.isFavorite,
                    )
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  'assets/icon/favorite-star.svg',
                  color: doctor.isFavorite? ConstantsV2.accentRegular: null,
                ),
              ),
            ),
          );
        },

      ),
    );
  }

  void getDoctors(){
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
          names: Provider.of<DoctorFilterProvider>(
              context,
              listen: false)
              .getNamesApplied,
        )
    );
  }

  void getMoreDoctors(){
    BlocProvider.of<DoctorsAvailableBloc>(context)
        .add(GetMoreFilterDoctor(
        organizations:
        Provider.of<DoctorFilterProvider>(
            context,
            listen: false
        ).getOrganizationsApplied,
        offset: offsetAllDoctors,
        specializations:
        Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getSpecializationsApplied,
        virtualAppointment: Provider.of<
            DoctorFilterProvider>(
            context,
            listen: false)
            .getLastVirtualAppointmentApplied,
        inPersonAppointment:
        Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getLastInPersonAppointmentApplied,
        names: Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getNamesApplied));
  }

  void getRecentDoctors(){
    BlocProvider.of<RecentDoctorsBloc>(context)..add(
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
        names: Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getNamesApplied,
      ),
    );
  }

  void getFavoriteDoctors(){
    BlocProvider.of<FavoriteDoctorsBloc>(context)
        .add(GetFavoriteDoctors(
        organizations:
        Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getOrganizationsApplied,
        specializations:
        Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getSpecializationsApplied,
        virtualAppointment: Provider.of<
            DoctorFilterProvider>(
            context,
            listen: false)
            .getLastVirtualAppointmentApplied,
        inPersonAppointment:
        Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getLastInPersonAppointmentApplied,
        names: Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getNamesApplied
    ),
    );
  }

  void getMoreFavoriteDoctors(){
    BlocProvider.of<FavoriteDoctorsBloc>(context)
        .add(GetMoreFavoriteDoctors(
        organizations:
        Provider.of<DoctorFilterProvider>(
            context,
            listen: false
        ).getOrganizationsApplied,
        offset: offsetFavoriteDoctors,
        specializations:
        Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getSpecializationsApplied,
        virtualAppointment: Provider.of<
            DoctorFilterProvider>(
            context,
            listen: false)
            .getLastVirtualAppointmentApplied,
        inPersonAppointment:
        Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getLastInPersonAppointmentApplied,
        names: Provider.of<DoctorFilterProvider>(
            context,
            listen: false)
            .getNamesApplied));
  }
  
}
