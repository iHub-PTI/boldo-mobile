import 'package:boldo/constants.dart';
import 'package:boldo/models/Prescription.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/screens/dashboard/tabs/components/appointment_card.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_state.dart';
import 'package:boldo/screens/dashboard/tabs/components/home_tab_appbar.dart';
import 'package:boldo/screens/dashboard/tabs/components/waiting_room_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:boldo/network/http.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  Isolate? _isolate;
  ReceivePort? _receivePort;

  List<Appointment> allAppointmentsState = [];

  List<Appointment> upcomingWaitingRoomAppointments = [];
  List<Appointment> waitingRoomAppointments = [];

  bool _dataFetchError = false;
  bool _loading = true;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  DateTime dateOffset = DateTime.now().subtract(const Duration(days: 30));
  void _onRefresh() async {
    setState(() {
      dateOffset = DateTime.now().subtract(const Duration(days: 30));
    });
    // monitor network fetch
    await getAppointmentsData(loadMore: false);
  }

  @override
  void initState() {
    getAppointmentsData(loadMore: false);

    super.initState();
  }

  @override
  void dispose() {
    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }
    if (_receivePort != null) {
      _receivePort!.close();
      _receivePort = null;
    }

    super.dispose();
  }

  static void _updateWaitingRoomsList(Map map) async {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      for (Appointment appointment in map["upcomingWaitingRoomAppointments"]) {
        if (DateTime.now()
            .add(const Duration(minutes: 15))
            .isAfter(DateTime.parse(appointment.start!).toLocal())) {
          timer.cancel();
          map['port'].send({"newAppointment": appointment});
          break;
        }
      }
    });
  }

  void _handleWaitingRoomsListUpdate(dynamic data) async {
    _isolate!.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort!.close();
    _receivePort = null;
    //if appointment doesnt exist in the list of appointments then update the state
    bool hasAppointment = waitingRoomAppointments
        .any((element) => element.id == data["newAppointment"].id);
    List<Appointment> updatedUpcomingAppointments =
        upcomingWaitingRoomAppointments
            .where((element) => element.id != data["newAppointment"].id)
            .toList();
    if (!mounted) return;
    if (!hasAppointment) {
      setState(() {
        upcomingWaitingRoomAppointments = updatedUpcomingAppointments;
        waitingRoomAppointments = [
          ...waitingRoomAppointments,
          data["newAppointment"]
        ];
      });
    }
    if (updatedUpcomingAppointments.isEmpty) return;
    _receivePort = ReceivePort();
    // restart the isolate with new data
    _isolate = await Isolate.spawn(
      _updateWaitingRoomsList,
      {
        'port': _receivePort!.sendPort,
        'upcomingWaitingRoomAppointments': updatedUpcomingAppointments,
      },
    );
    _receivePort!.listen(_handleWaitingRoomsListUpdate);
  }

  Future<void> getAppointmentsData({bool loadMore = false}) async {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
    if (!loadMore) {
      if (_isolate != null) {
        _isolate!.kill(priority: Isolate.immediate);
        _isolate = null;
      }
      if (_receivePort != null) {
        _receivePort!.close();
        _receivePort = null;
      }
      if (!isAuthenticated) {
        setState(() {
          _loading = false;
          _dataFetchError = false;
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _loading = true;
        _dataFetchError = false;
      });
    }

    try {
      Response responseAppointments = await dio.get(
          "/profile/patient/appointments?start=${dateOffset.toUtc().toIso8601String().substring(0, 23)}Z");
      Response responsePrescriptions =
          await dio.get("/profile/patient/prescriptions");

      List<Prescription> allPrescriptions = List<Prescription>.from(
          responsePrescriptions.data["prescriptions"]
              .map((i) => Prescription.fromJson(i)));

      List<Appointment> allAppointmets = List<Appointment>.from(
          responseAppointments.data["appointments"]
              .map((i) => Appointment.fromJson(i)));

      for (Appointment appointment in allAppointmets) {
        for (Prescription prescription in allPrescriptions) {
          if (prescription.encounter != null &&
              prescription.encounter!.appointmentId! == appointment.id) {
            if (appointment.prescriptions != null) {
              appointment.prescriptions = [
                ...appointment.prescriptions!,
                prescription
              ];
            } else {
              appointment.prescriptions = [prescription];
            }
          }
        }
      }

      if (!mounted) return;

      List<Appointment> pastAppointmentsItems = allAppointmets
          .where((element) => ["closed", "locked"].contains(element.status))
          .toList();
      List<Appointment> upcomingAppointmentsItems = allAppointmets
          .where((element) => !["closed", "locked"].contains(element.status))
          .toList();
      allAppointmets = [...upcomingAppointmentsItems, ...pastAppointmentsItems];

      allAppointmets.sort(
          (a, b) => DateTime.parse(b.start!).compareTo(DateTime.parse(a.start!)));

      List<Appointment> upcomingWaitingRoomAppointmetsList = allAppointmets
          .where((element) =>
              element.status == "upcoming" &&
              DateTime.now()
                  .add(const Duration(minutes: 15))
                  .isBefore(DateTime.parse(element.start!).toLocal()))
          .toList();
      if (!mounted) return;
      if (!loadMore) {
        _receivePort = ReceivePort();
        _isolate = await Isolate.spawn(
          _updateWaitingRoomsList,
          {
            'port': _receivePort!.sendPort,
            'upcomingWaitingRoomAppointments':
                upcomingWaitingRoomAppointmetsList,
          },
        );
        _receivePort!.listen(_handleWaitingRoomsListUpdate);
      }

      if (!mounted) return;
      setState(() {
        _dataFetchError = false;
        _loading = false;
        upcomingWaitingRoomAppointments = upcomingWaitingRoomAppointmetsList;
        waitingRoomAppointments = allAppointmets.where(
          (element) {
            if (element.status == "open") {
              return true;
            }

            if (element.status == "upcoming" &&
                DateTime.now()
                    .add(const Duration(minutes: 15))
                    .isAfter(DateTime.parse(element.start!).toLocal())) {
              return true;
            }
            return false;
          },
        ).toList();

        allAppointmentsState = [
          ...allAppointmets,
        ];
      });
    } on DioError catch (exception, stackTrace) {
      print(exception);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _dataFetchError = true;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _dataFetchError = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } finally {
      if (_refreshController != null) {
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
    Appointment firstPastAppointment = allAppointmentsState.firstWhere(
        (element) => ["closed", "locked"].contains(element.status),
        // ignore: null_check_always_fails
        orElse: () => null!);

    return Scaffold(
      appBar: const HomeTabAppBar(),
      body: _dataFetchError
          ? DataFetchErrorWidget(retryCallback: getAppointmentsData)
          : _loading
              ? const Center(
                  child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                  backgroundColor: Constants.primaryColor600,
                ))
              : !isAuthenticated || allAppointmentsState.isEmpty
                  ? const EmptyAppointmentsState(
                      size: "big", text: "Agrega tu primera cita")
                  : SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      header: const MaterialClassicHeader(
                        color: Constants.primaryColor800,
                      ),
                      controller: _refreshController,
                      onLoading: () {
                        dateOffset =
                            dateOffset.subtract(const Duration(days: 30));
                        setState(() {});
                        getAppointmentsData(loadMore: true);
                      },
                      onRefresh: _onRefresh,
                      footer: CustomFooter(
                        height: 140,
                        builder: (BuildContext context, LoadStatus? mode) {
                          Widget body = Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Mostrando datos hasta ${DateFormat('dd MMMM yyyy').format(dateOffset)}",
                                style: const TextStyle(
                                  color: Constants.primaryColor800,
                                ),
                              )
                            ],
                          );

                          if (mode! == LoadStatus.loading) {
                            body = Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "cargando datos ...",
                                  style: TextStyle(
                                    color: Constants.primaryColor800,
                                  ),
                                )
                              ],
                            );
                          }
                          return Column(
                            children: [
                              const SizedBox(height: 30),
                              Center(child: body),
                            ],
                          );
                        },
                      ),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                for (Appointment appointment
                                    in waitingRoomAppointments)
                                  WaitingRoomCard(
                                      appointment: appointment,
                                      getAppointmentsData: getAppointmentsData),
                              ],
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              for (int i = 0;
                                  i < allAppointmentsState.length;
                                  i++)
                                _ListRenderer(
                                  index: i,
                                  appointment: allAppointmentsState[i],
                                  firstAppointmentPast: firstPastAppointment,
                                  waitingRoomAppointments:
                                      waitingRoomAppointments,
                                ),
                            ]),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class _ListRenderer extends StatelessWidget {
  final int? index;
  final Appointment? appointment;
  final Appointment? firstAppointmentPast;
  final List<Appointment>? waitingRoomAppointments;

  const _ListRenderer(
      {Key? key,
      this.index,
      this.appointment,
      this.firstAppointmentPast,
      @required this.waitingRoomAppointments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isInWaitingRoom = waitingRoomAppointments!
        .any((element) => element.id == appointment!.id);
    if (index == 0 && !["closed", "locked"].contains(appointment!.status))
      return Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 18),
            child: Text(
              "Próximas Citas",
              style: boldoSubTextStyle.copyWith(
                fontSize: 14,
                color: const Color(0xff6B7280),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 18,
            top: 7,
            left: 10,
            right: 10,
          ),
          width: double.infinity,
          color: const Color(0xffE5E7EB),
          height: 1,
        ),
        AppointmentCard(
            appointment: appointment!, isInWaitingRoom: isInWaitingRoom),
      ]);
    if (firstAppointmentPast != null &&
        firstAppointmentPast!.id == appointment!.id) {
      return Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 18),
            child: Text(
              "Citas Pasadas",
              style: boldoSubTextStyle.copyWith(
                fontSize: 14,
                color: const Color(0xff6B7280),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 18,
            top: 7,
            left: 10,
            right: 10,
          ),
          width: double.infinity,
          color: const Color(0xffE5E7EB),
          height: 1,
        ),
        AppointmentCard(
            appointment: appointment!, isInWaitingRoom: isInWaitingRoom),
      ]);
    }
    return AppointmentCard(
        appointment: appointment!, isInWaitingRoom: isInWaitingRoom);
  }
}
