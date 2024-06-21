import 'package:boldo/app_config.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/features/doctor_search/presentation/presentation.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DoctorsFavoriteWidget extends StatefulWidget {
  const DoctorsFavoriteWidget({
    required this.doctors,
    required this.updateFavoriteStatus,
    super.key,
  });

  /// The [Doctor] that will change his favorite status
  final List<Doctor> doctors;

  /// Function that will be call if the action is success
  final void Function({required Doctor doctor}) updateFavoriteStatus;

  @override
  State<DoctorsFavoriteWidget> createState() => _DoctorsFavoriteWidgetState();
}

class _DoctorsFavoriteWidgetState extends State<DoctorsFavoriteWidget>
    with AutomaticKeepAliveClientMixin {
  //list of doctors for tabs
  List<Doctor> doctors = [];
  List<Doctor> recentDoctors = [];
  List<Doctor> favoritesDoctors = [];

  // initial value
  int offsetFavoriteDoctors = 0;

  int maxSizeFavoriteDoctors = 0;

  //controllers for smartRefresh to pull and get more doctors

  final RefreshController _refreshFavoriteDoctorController =
      RefreshController();

  final GlobalKey<AnimatedGridState> gridFavoriteDoctorsKey =
      GlobalKey<AnimatedGridState>();

  final Duration durationFavoriteAction = const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    getFavoriteDoctors();
  }

  @override
  void dispose() {
    super.dispose();
    _refreshFavoriteDoctorController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    return BlocListener<FavoriteDoctorsBloc, FavoriteDoctorsState>(
      listener: (context, state) {
        if (state is FavoriteDoctorsLoaded) {
          _refreshFavoriteDoctorController
            ..refreshCompleted()
            ..loadComplete();
          favoritesDoctors.clear();
          maxSizeFavoriteDoctors = state.doctors.total ?? 0;

          state.doctors.items?.removeWhere(
            (newDoctor) =>
                favoritesDoctors.any((doctor) => newDoctor.id == doctor.id),
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
            (newDoctor) =>
                favoritesDoctors.any((doctor) => newDoctor.id == doctor.id),
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
        } else if (state is FavoriteDoctorsAdded) {
          updateFavoriteStatus(doctor: state.doctor);
        }
      },
      child: Container(
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
      ),
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
                          widget.updateFavoriteStatus(
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
    if (doctorAction.isFavorite) {
      if (!favoritesDoctors.any((element) => element.id == doctor.id)) {
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
      }
    } else {
      try {
        final index = favoritesDoctors.lastIndexWhere(
          (element) => element.id == doctorAction.id,
        );

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

        favoritesDoctors.removeAt(index);
      } catch (error) {
        //none
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
