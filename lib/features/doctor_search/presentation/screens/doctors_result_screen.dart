import 'package:boldo/blocs/goToTop_bloc/goToTop_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/features/doctor_search/doctor_search.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/models/filters/DoctorFilter.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/filter/filters_applied.dart';
import 'package:boldo/widgets/go_to_top.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// List of doctors available in patient common organization
class DoctorsResult extends StatefulWidget {
  /// List of doctors available in patient common organization
  const DoctorsResult({
    super.key,
  });

  /// String route name to redirect to this screen
  static String routeName = '/doctor-result';
  @override
  _DoctorsResultState createState() => _DoctorsResultState();
}

// STATE CLASS
class _DoctorsResultState extends State<DoctorsResult>
    with SingleTickerProviderStateMixin {
  // filter provider
  late DoctorFilterProvider _myProvider;

  //list of doctors for tabs
  PagList<Doctor> doctors = PagList();

  // initial value
  int offsetAllDoctors = 0;

  int maxSizeAllDoctors = 0;

  //controllers for smartRefresh to pull and get more doctors
  final RefreshController _refreshDoctorController = RefreshController();

  // scroll controller
  ScrollController scrollDoctorList = ScrollController();

  final Duration durationFavoriteAction = const Duration(seconds: 1);

  @override
  void initState() {
    _myProvider = Provider.of<DoctorFilterProvider>(context, listen: false);

    doctors = _myProvider.getDoctorsSaved;

    super.initState();
  }

  @override
  void dispose() {
    _myProvider.clearFilter();
    _refreshDoctorController.dispose();
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
              BlocListener<DoctorsResultBloc, DoctorsResultState>(
                listener: (context, state) {
                  if (state is DoctorsResultLoaded) {
                    maxSizeAllDoctors = state.doctors.total ?? 0;
                    offsetAllDoctors = 0;
                    setState(() {
                      doctors = state.doctors;
                    });
                    Provider.of<DoctorFilterProvider>(
                      context,
                      listen: false,
                    ).setDoctors(doctors: doctors);
                  } else if (state is MoreDoctorsResultLoaded) {
                    if (mounted) {
                      _refreshDoctorController
                        ..refreshCompleted()
                        ..loadComplete();
                      maxSizeAllDoctors = state.doctors.total ?? 0;

                      state.doctors.items?.removeWhere(
                        (newDoctor) =>
                            doctors.items
                                ?.any((doctor) => newDoctor.id == doctor.id) ??
                            false,
                      );

                      setState(() {
                        doctors.items?.addAll(state.doctors.items ?? []);
                      });
                    }
                  } else if (state is FailedResult) {
                    _refreshDoctorController
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
                        labelText: 'Resultados',
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
                                    fromResult: true,
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
                BlocBuilder<DoctorsResultBloc, DoctorsResultState>(
                  builder: (context, state) {
                    if (state is LoadingResults) {
                      return loadingStatus();
                    } else if (state is FailedResult) {
                      return DataFetchErrorWidget(
                        retryCallback: () {
                          getDoctors();
                        },
                      );
                    } else {
                      return doctors.items?.isNotEmpty ?? false
                          ? Flexible(child: _allDoctors())
                          : _emptyDoctor();
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
                      fromResult: true,
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

  Widget _allDoctors() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: FiltersApplied<DoctorFilter>(
              filter: _myProvider.doctorFilter,
              filterCallback: (DoctorFilter filter) {
                _myProvider.doctorFilter = filter;
                BlocProvider.of<DoctorsResultBloc>(context).add(
                  GetDoctorsResult(
                    names: filter.getNamesApplied,
                    specializations: filter.getSpecializationsApplied,
                    organizations: filter.getOrganizationsApplied,
                    inPersonAppointment:
                        filter.getLastInPersonAppointmentApplied,
                    virtualAppointment: filter.getLastVirtualAppointmentApplied,
                  ),
                );
              },
            ),
          ),
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
              doctors: doctors.items ?? [],
              updateFavoriteStatus: updateFavoriteStatus,
            ),
          ),
        ],
      ),
    );
  }

  void getDoctors() {
    BlocProvider.of<DoctorsResultBloc>(context).add(
      GetDoctorsResult(
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
    BlocProvider.of<DoctorsResultBloc>(context).add(
      GetMoreDoctorsResult(
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
    doctor.isFavorite = !doctor.isFavorite;

    // update view
    setState(() {});
  }
}
