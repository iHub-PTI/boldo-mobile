import 'package:boldo/blocs/doctors_available_bloc/doctors_available_bloc.dart';
import 'package:boldo/blocs/user_bloc/patient_bloc.dart' as patientBloc;
import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/provider/doctor_filter_provider.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/doctor_profile/doctor_profile_screen.dart';
import 'package:boldo/screens/doctor_search/doctor_filter.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/go_to_top.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
class _DoctorsAvailableState extends State<DoctorsAvailable> {
  bool _loading = true;
  List<Doctor> doctors = [];
  // initial value
  int offset = 0;
  RefreshController _refreshDoctorController =
      RefreshController(initialRefresh: false);
  // scroll controller
  ScrollController scrollDoctorList = ScrollController();
  // flag for show or not the scroll button
  bool showAnimatedButton = false;
  bool _getDoctorsFailed = false;
  bool _getFilterDoctorsFailed = false;
  List<Doctor>? doctorsSaved;
  @override
  void initState() {

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
                .getLastInPersonAppointmentApplied
        )
    );
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
    super.initState();
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
        child: BlocListener<DoctorsAvailableBloc, DoctorsAvailableState>(
          listener: (context, state) {
            if (state is Loading) {
              setState(() {
                _loading = true;
              });
            } else if (state is FilterLoadingInDoctorList) {
              setState(() {
                _loading = true;
              });
            } else if (state is Success) {
              setState(() {
                _loading = false;
              });
            } else if (state is FilterSuccesInDoctorList) {
              setState(() {
                _loading = false;
              });
            } else if (state is DoctorsLoaded) {
              setState(() {
                doctors = state.doctors;
              });
            } else if (state is MoreDoctorsLoaded) {
              if (mounted) {
                _refreshDoctorController.refreshCompleted();
                _refreshDoctorController.loadComplete();
                setState(() {
                  doctors = [...doctors, ...state.doctors];
                });
              }
            } else if (state is FilterLoadedInDoctorList) {
              setState(() {
                doctors = state.doctors;
              });
            } else if (state is FilterFailedInDoctorList) {
              setState(() {
                _getFilterDoctorsFailed = true;
              });
            } else if (state is Failed) {
              setState(() {
                _getDoctorsFailed = true;
              });
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 25,
                          color: Constants.extraColor400,
                        ),
                        label: Text(
                          'Médicos disponibles',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorFilter(),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                              'assets/icon/change-filter.svg'))
                    ],
                  ),
                ),
                BlocBuilder<DoctorsAvailableBloc, DoctorsAvailableState>(
                  builder: (context, state){
                    if(state is Loading || state is FilterLoading)
                      return const Center(child: CircularProgressIndicator());
                    else if(state is Failed){
                      return DataFetchErrorWidget(
                          retryCallback: () =>
                            GetDoctorsAvailable(
                                organizations: Provider.of<DoctorFilterProvider>(context, listen: false)
                                    .getOrganizationsApplied,
                                offset: offset
                            )
                      );
                    }else{
                      return
                        doctors.isNotEmpty
                            ? Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(right: 16, left: 16),
                            child: SmartRefresher(
                              controller: _refreshDoctorController,
                              enablePullUp: true,
                              enablePullDown: true,
                              child: GridView.builder(
                                physics: ScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                controller: scrollDoctorList,
                                gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 200,
                                    childAspectRatio: 3 / 4,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20),
                                itemCount: doctors.length,
                                itemBuilder: doctorItem,
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
                                offset = 0;
                                if (Provider.of<DoctorFilterProvider>(context,
                                    listen: false)
                                    .getSpecializationsApplied ==
                                    null) {
                                  BlocProvider.of<DoctorsAvailableBloc>(
                                      context)
                                      .add(GetDoctorsAvailable(
                                      organizations: Provider.of<DoctorFilterProvider>(context, listen: false)
                                          .getOrganizationsApplied,
                                      offset: 0
                                      ));
                                } else {
                                  BlocProvider.of<DoctorsAvailableBloc>(context)
                                      .add(GetDoctorFilterInDoctorList(
                                      organizations:
                                      Provider.of<DoctorFilterProvider>(
                                          context,
                                          listen: false)
                                          .getOrganizationsApplied,
                                      specializations:
                                      Provider.of<DoctorFilterProvider>(
                                          context,
                                          listen: false)
                                          .getSpecializationsApplied!,
                                      virtualAppointment: Provider.of<
                                          DoctorFilterProvider>(
                                          context,
                                          listen: false)
                                          .getLastVirtualAppointmentApplied!,
                                      inPersonAppointment:
                                      Provider.of<DoctorFilterProvider>(
                                          context,
                                          listen: false)
                                          .getLastInPersonAppointmentApplied!));
                                }
                              },
                              // this for load more doctors
                              onLoading: () {
                                offset = offset + 20;
                                if (Provider.of<DoctorFilterProvider>(context,
                                    listen: false)
                                    .getSpecializationsApplied ==
                                    null) {
                                  // new event for get more available doctor
                                  BlocProvider.of<DoctorsAvailableBloc>(
                                      context)
                                      .add(GetMoreDoctorsAvailable(
                                      organizations:
                                      Provider.of<DoctorFilterProvider>(
                                          context,
                                          listen: false
                                      ).getOrganizationsApplied,
                                      offset: offset));
                                } else {
                                  BlocProvider.of<DoctorsAvailableBloc>(context)
                                      .add(GetMoreFilterDoctor(
                                      organizations:
                                      Provider.of<DoctorFilterProvider>(
                                          context,
                                          listen: false
                                      ).getOrganizationsApplied,
                                      offset: offset,
                                      specializations:
                                      Provider.of<DoctorFilterProvider>(
                                          context,
                                          listen: false)
                                          .getSpecializationsApplied!,
                                      virtualAppointment: Provider.of<
                                          DoctorFilterProvider>(
                                          context,
                                          listen: false)
                                          .getLastVirtualAppointmentApplied!,
                                      inPersonAppointment:
                                      Provider.of<DoctorFilterProvider>(
                                          context,
                                          listen: false)
                                          .getLastInPersonAppointmentApplied!));
                                }
                              },
                            ),
                          ),
                        )
                            : const Center(
                          child: Text('No se encontraron doctores'),
                        );
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
      available = 'Disponible Hoy!';
    } else if (daysDifference > 0) {
      available =
          'Disponible ${DateFormat('EEEE, dd MMMM', Localizations.localeOf(context).languageCode).format(parsedAvailability)}';
    }
    return available;
  }

  Widget doctorItem(BuildContext context, index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfileScreen(
              doctor: doctors[index],
              showAvailability: true,
            ),
          ),
        );
      },
      child: Stack(
        children: <Widget>[
          // the first item in stack is the doctor profile photo
          doctors[index].photoUrl != null
              ? Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      image: DecorationImage(
                          image: NetworkImage(doctors[index].photoUrl!),
                          fit: BoxFit.cover)),
                )
              : Card(
                  margin: EdgeInsets.all(0),
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: doctors[index].gender == 'female'
                      ? SvgPicture.asset(
                          'assets/images/femaleDoctor.svg',
                          fit: BoxFit.cover,
                        )
                      : SvgPicture.asset(
                          'assets/images/maleDoctor.svg',
                          fit: BoxFit.cover,
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const RadialGradient(
                  radius: 4,
                  center: Alignment(
                    1.80,
                    0.77,
                  ),
                  //center: Alignment.center,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0),
                    Color.fromRGBO(0, 0, 0, 1),
                  ]),
            ),
          ),
          // the second item in stack is the column of details
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            left: 24.0, right: 16, bottom: 2),
                        child: Text(
                          '${doctors[index].gender == 'female' ? 'Dra.' : 'Dr.'} ${doctors[index].givenName!.split(" ")[0]} ${doctors[index].familyName!.split(" ")[0]}',
                          style: boldoCardHeadingTextStyle,
                        ),
                      ),
                    ],
                  ))
                ],
              ),
              // specializations
              doctors[index].specializations != null
                  ? doctors[index].specializations!.length > 0
                      ? Container(
                          // 52 is the sum of left and right padding plus the space between columns
                          width: MediaQuery.of(context).size.width / 2 - 52,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 24.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    for (int i = 0;
                                        i <
                                            doctors[index]
                                                .specializations!
                                                .length;
                                        i++)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: i == 0 ? 0 : 3.0, bottom: 8),
                                        child: Text(
                                          "${doctors[index].specializations![i].description}${doctors[index].specializations!.length > 1 && i == 0 ? "," : ""}",
                                          style: boldoCorpMediumWithLineSeparationLargeTextStyle
                                              .copyWith(
                                                  color: ConstantsV2
                                                      .buttonPrimaryColor100,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              )),
                        )
                      : Container()
                  : Container(),
              Container(
                width: MediaQuery.of(context).size.width / 2 - 52,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          availableText(doctors[index].organizations?.first.nextAvailability),
                          style: boldoCorpSmallInterTextStyle.copyWith(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4)
            ],
          ),
        ],
      ),
    );
  }
}
