import 'package:boldo/blocs/appointmet_bloc/appointmentBloc.dart';
import 'package:boldo/blocs/homeAppointments_bloc/homeAppointments_bloc.dart';
import 'package:boldo/blocs/medical_record_bloc/medicalRecordBloc.dart'as medical;
import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/screens/appointments/medicalRecordScreen.dart';
import 'package:boldo/screens/booking/booking_confirm_screen.dart';
import 'package:boldo/screens/dashboard/tabs/components/appointment_card.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';

import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PastAppointmentsScreen extends StatefulWidget {
  const PastAppointmentsScreen() : super();

  @override
  _PastAppointmentsScreenState createState() => _PastAppointmentsScreenState();
}

class _PastAppointmentsScreenState extends State<PastAppointmentsScreen> with SingleTickerProviderStateMixin {
  bool _dataLoading = true;
  bool _dataLoaded = false;
  int _selectedIndex = 0;
  late TabController _tabController;
  late List<Appointment> allAppointments = [];
  late List<Appointment> futureAppointments = [];
  DateTime dateOffset = DateTime.now().subtract(const Duration(days: 30));

  RefreshController? _refreshFutureAppointmentController =
  RefreshController(initialRefresh: false);

  RefreshController? _refreshPastAppointmentController =
  RefreshController(initialRefresh: false);

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
    );


    _tabController.addListener(() {
      // to show specific icons according to tab selected
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });

    // get future appointments
    BlocProvider.of<HomeAppointmentsBloc>(context).add(GetAppointmentsHome());

    // get past appointments
    BlocProvider.of<AppointmentBloc>(context).add(GetPastAppointmentBetweenDatesList());
    super.initState();
  }

  void _onRefreshFutureAppointments() async {
    // monitor network fetch
    BlocProvider.of<HomeAppointmentsBloc>(context).add(GetAppointmentsHome());
  }

  @override
  void dispose(){
    _tabController.dispose();
    _refreshFutureAppointmentController?.dispose();
    _refreshPastAppointmentController?.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    setState(() {
      dateOffset = DateTime.now().subtract(const Duration(days: 30));
    });
    // monitor network fetch
    BlocProvider.of<AppointmentBloc>(context).add(GetPastAppointmentBetweenDatesList());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppointmentBloc, AppointmentState>(
          listener: (context, state) {
            if (state is Success) {
              setState(() {
                _dataLoading = false;
                _dataLoaded = true;
              });
            } else if (state is Failed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response!),
                  backgroundColor: Colors.redAccent,
                ),
              );
              if (_refreshPastAppointmentController != null) {
                _refreshPastAppointmentController!.refreshCompleted();
                _refreshPastAppointmentController!.loadComplete();
              }
              _dataLoading = false;
              _dataLoaded = false;
            } else if (state is AppointmentLoadedState) {
              allAppointments = state.appointments;
              if (_refreshFutureAppointmentController != null) {
                _refreshPastAppointmentController!.refreshCompleted();
                _refreshPastAppointmentController!.loadComplete();
              }
            }
          }
        ),
        BlocListener<HomeAppointmentsBloc, HomeAppointmentsState>(
          listener: (context, state) {
            if (state is FailedLoadedAppointments) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response!),
                  backgroundColor: Colors.redAccent,
                ),
              );
              if (_refreshFutureAppointmentController != null) {
                _refreshFutureAppointmentController!.refreshCompleted();
                _refreshFutureAppointmentController!.loadComplete();
              }
            }
            if (state is AppointmentsHomeLoaded) {
              futureAppointments = state.appointments;
              if (_refreshFutureAppointmentController != null) {
                _refreshFutureAppointmentController!.refreshCompleted();
                _refreshFutureAppointmentController!.loadComplete();
              }
            }
          },
        ),
      ],
      child: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: SvgPicture.asset('assets/Logo.svg',
                semanticsLabel: 'BOLDO Logo'),
          ),
        ),
        body: _dataLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                  backgroundColor: Constants.primaryColor600,
                ),
              )
            : Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 25,
                          color: Constants.extraColor400,
                        ),
                        label: Text(
                          'Mis Consultas',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                        ),
                      ),
                    ),
                    if (!_dataLoading && !_dataLoaded)
                      const Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Center(
                          child: Text(
                            "Algo salió mal. Por favor, inténtalo de nuevo más tarde.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.otherColor100,
                            ),
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Center(
                            child: SvgPicture.asset(
                              'assets/decorations/line_separator.svg',
                            )
                          ),
                          TabBar(
                            labelStyle: boldoTabHeaderSelectedTextStyle,
                            unselectedLabelStyle: boldoTabHeaderUnselectedTextStyle,
                            indicatorColor: Colors.transparent,
                            unselectedLabelColor:
                            const Color.fromRGBO(119, 119, 119, 1),
                            labelColor: ConstantsV2.activeText,
                            controller: _tabController,
                            tabs: [
                              const Text(
                                'Próximas',
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Anteriores',
                                  ),
                                  if(_selectedIndex == 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        await _filterBox();
                                      },
                                      child: SvgPicture.asset(
                                        'assets/icon/filter-list.svg',
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildFutureAppointments(),
                            _buildPastAppointments(),
                          ],
                        ),
                      ),

                  ],
                ),
              ),
      );
    }));
  }

  Widget _buildFutureAppointments() {
    return Container(
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const MaterialClassicHeader(
          color: Constants.primaryColor800,
        ),
        controller: _refreshFutureAppointmentController!,
        onRefresh: _onRefreshFutureAppointments,
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
            return futureAppointments.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              itemCount: futureAppointments.length,
              scrollDirection: Axis.vertical,
              itemBuilder: _appointment,
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

  Widget _buildPastAppointments() {
    return Container(
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const MaterialClassicHeader(
          color: Constants.primaryColor800,
        ),
        controller: _refreshPastAppointmentController!,
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
        child: BlocBuilder<AppointmentBloc, AppointmentState>(builder: (context, state) {
          if(state is Success){
            return allAppointments.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              itemCount: allAppointments.length,
              scrollDirection: Axis.vertical,
              itemBuilder: _pastAppointment,
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
          }else if(state is Loading){
            return Container(
                child: const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                      backgroundColor: Constants.primaryColor600,
                    )
                )
            );
          }else if(state is Failed){
            return Container(
              child: DataFetchErrorWidget(
                retryCallback: () => BlocProvider.of<AppointmentBloc>(context)
                  .add(
                  GetPastAppointmentBetweenDatesList()
                )
              )
            );
          }else{
            return Container();
          }
        }),
      ),
    );
  }

  Widget _appointment(BuildContext context, int index) {
    return AppointmentCard(
      appointment: futureAppointments[index],
      isInWaitingRoom: futureAppointments[index].status == "open",
      showCancelOption: true,
    );
  }

  Widget _pastAppointment(BuildContext context, int index) {
    return PastAppointmentCard(
      appointment: allAppointments[index],
    );
  }
  Future _filterBox(){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController dateTextController = TextEditingController();
        TextEditingController date2TextController = TextEditingController();
        var inputFormat = DateFormat('dd/MM/yyyy');
        var outputFormat = DateFormat('yyyy-MM-dd');
        DateTime date1 = BlocProvider.of<AppointmentBloc>(context).getInitialDate();
        DateTime? date2 = BlocProvider.of<AppointmentBloc>(context).getFinalDate();
        bool virtual = BlocProvider.of<AppointmentBloc>(context).getVirtualStatus();
        bool inPerson = BlocProvider.of<AppointmentBloc>(context).getInPersonStatus();

        dateTextController.text = inputFormat.format(date1);
        date2TextController.text = date2 != null? inputFormat.format(date2) :'';
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                contentPadding: const EdgeInsetsDirectional.all(0),
                scrollable: true,
                backgroundColor: ConstantsV2.lightGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.9,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Filtrar citas',
                              style: boldoTitleBlackTextStyle.copyWith(
                                  color: ConstantsV2.activeText
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                              },
                              child: SvgPicture.asset(
                                'assets/icon/close.svg',
                                color: ConstantsV2.inactiveText,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  color: ConstantsV2.lightest,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Text('Modalidad',
                                            style: boldoCorpSmallSTextStyle.copyWith(
                                                color: ConstantsV2.activeText
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: inPerson,
                                              onChanged: (value) {
                                                setState(() {
                                                  inPerson = value!;
                                                });
                                              }
                                            ),
                                            Container(
                                              child: Text(
                                                "Presencial",
                                                style: boldoCorpMediumTextStyle.copyWith(
                                                    color: ConstantsV2.activeText
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: virtual,
                                              onChanged: (value) {
                                                setState(() {
                                                  virtual = value!;
                                                });
                                              }
                                            ),
                                            Container(
                                              child: Text(
                                                "Remoto",
                                                style: boldoCorpMediumTextStyle.copyWith(
                                                    color: ConstantsV2.activeText
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                              ),
                              Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  color: ConstantsV2.lightest,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Text('Filtrar por fecha',
                                            style: boldoCorpSmallSTextStyle.copyWith(
                                                color: ConstantsV2.activeText
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  DateTime? newDate = await showDatePicker(
                                                    context: context,
                                                    initialEntryMode: DatePickerEntryMode
                                                        .calendarOnly,
                                                    initialDatePickerMode: DatePickerMode.day,
                                                    initialDate: date1 ?? DateTime.now(),
                                                    firstDate: DateTime(1900),
                                                    lastDate: date2?? DateTime.now(),
                                                    locale: const Locale("es", "ES"),
                                                  );
                                                  if (newDate == null) {
                                                    return;
                                                  } else {
                                                    setState(() {
                                                      var outputFormat = DateFormat('yyyy-MM-dd');
                                                      var inputFormat = DateFormat('dd/MM/yyyy');
                                                      var _date1 =
                                                      outputFormat.parse(newDate.toString().trim());
                                                      var _date2 = inputFormat.format(_date1);
                                                      dateTextController.text = _date2;
                                                      date1 = _date1;
                                                    });
                                                  }
                                                },
                                                child: SvgPicture.asset(
                                                  'assets/icon/calendar.svg',
                                                  color: ConstantsV2.orange,
                                                  height: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 6,),
                                              Text('Desde: ${inputFormat.format(date1)}',
                                                style: boldoCorpSmallSTextStyle.copyWith(
                                                    color: ConstantsV2.activeText
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  DateTime? newDate = await showDatePicker(
                                                    context: context,
                                                    initialEntryMode: DatePickerEntryMode
                                                        .calendarOnly,
                                                    initialDatePickerMode: DatePickerMode.day,
                                                    initialDate: date2 ?? date1,
                                                    firstDate: date1,
                                                    lastDate: DateTime.now(),
                                                    locale: const Locale("es", "ES"),
                                                  );
                                                  if (newDate == null) {
                                                    return;
                                                  } else {
                                                    setState(() {
                                                      var outputFormat = DateFormat('yyyy-MM-dd');
                                                      var inputFormat = DateFormat('dd/MM/yyyy');
                                                      var _date1 =
                                                      outputFormat.parse(newDate.toString().trim());
                                                      var _date2 = inputFormat.format(_date1);
                                                      date2TextController.text = _date2;
                                                      date2 = _date1;
                                                    });
                                                  }
                                                },
                                                child: SvgPicture.asset(
                                                  'assets/icon/calendar.svg',
                                                  color: ConstantsV2.orange,
                                                  height: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 6,),
                                              Text('Hasta: ${date2 != null ? inputFormat.format(
                                                  date2!) : 'indefinido'}',
                                                style: boldoCorpSmallSTextStyle.copyWith(
                                                    color: ConstantsV2.activeText
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed:() {
                                BlocProvider.of<AppointmentBloc>(context).setInitialDate(date1);
                                BlocProvider.of<AppointmentBloc>(context).setFinalDate(date2);
                                BlocProvider.of<AppointmentBloc>(context).setInPersonStatus(inPerson);
                                BlocProvider.of<AppointmentBloc>(context).setVirtualStatus(virtual);
                                BlocProvider.of<AppointmentBloc>(context).add(GetPastAppointmentBetweenDatesList());
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Text('Aplicar',
                                    style: boldoCorpSmallSTextStyle.copyWith(
                                        color: ConstantsV2.lightGrey
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    'assets/icon/done.svg',
                                    color: ConstantsV2.lightGrey,
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        );
      },
    );
  }

}

class PastAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const PastAppointmentCard({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int daysDifference = daysBetween(DateTime.now(),DateTime.parse(
        appointment.start!)
        .toLocal());
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MedicalRecordsScreen(
                      appointment:
                      appointment
                          )),
        );
        BlocProvider.of<medical.MedicalRecordBloc>(context)
            .add(medical.InitialEvent());
      },
      child: Container(
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
                  children: [
                    // Text(
                    //   "Consultaste con",
                    //   style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.darkBlue),
                    // ),
                    const Spacer(),
                    Text(
                      daysDifference == 0
                          ? "hoy"
                          : '${DateFormat('dd/MM/yy').format(DateTime.parse(appointment.start!).toLocal())}',
                      style: boldoCorpSmallTextStyle
                          .copyWith(
                          color: ConstantsV2
                              .inactiveText),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 8),
                      child: ClipOval(
                        child: SizedBox(
                          width: 54,
                          height: 54,
                          child: appointment
                              .doctor
                              ?.photoUrl ==
                              null
                              ? SvgPicture.asset(
                              appointment
                                  .doctor!
                                  .gender ==
                                  "female"
                                  ? 'assets/images/femaleDoctor.svg'
                                  : 'assets/images/maleDoctor.svg',
                              fit: BoxFit.cover)
                              : CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: appointment
                                .doctor!
                                .photoUrl ??
                                '',
                            progressIndicatorBuilder:
                                (context, url,
                                downloadProgress) =>
                                Padding(
                                  padding:
                                  const EdgeInsets
                                      .all(
                                      26.0),
                                  child:
                                  LinearProgressIndicator(
                                    value: downloadProgress
                                        .progress,
                                    valueColor: const AlwaysStoppedAnimation<
                                        Color>(
                                        Constants
                                            .primaryColor400),
                                    backgroundColor:
                                    Constants
                                        .primaryColor600,
                                  ),
                                ),
                            errorWidget: (context,
                                url,
                                error) =>
                            const Icon(Icons
                                .error),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "${getDoctorPrefix(appointment.doctor!.gender!)}${appointment.doctor!.familyName}",
                                  style:
                                  boldoSubTextMediumStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        if (appointment
                            .doctor!
                            .specializations !=
                            null &&
                            appointment
                                .doctor!
                                .specializations!
                                .isNotEmpty)
                          SizedBox(
                            width: MediaQuery.of(
                                context)
                                .size
                                .width -
                                90,
                            child:
                            SingleChildScrollView(
                              scrollDirection:
                              Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int i = 0;
                                  i <
                                      appointment
                                          .doctor!
                                          .specializations!
                                          .length;
                                  i++)
                                    Text(
                                      "${toLowerCase(appointment.doctor!.specializations![i].description ?? '')}${appointment.doctor!.specializations!.length > 1 && i < (appointment.doctor!.specializations!.length-1) ? ", " : ""}",
                                      style: boldoCorpMediumTextStyle
                                          .copyWith(
                                          color:
                                          ConstantsV2.inactiveText),
                                    ),
                                ],
                              ),
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
                        ShowAppoinmentTypeIcon(appointmentType: appointment.appointmentType!),
                        Text(
                          appointment.appointmentType == 'V' ? "Remoto" : "Presencial",
                          style: TextStyle(
                            color: appointment.appointmentType == 'V' ? ConstantsV2.orange : ConstantsV2.green,
                            fontSize: 12,
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
