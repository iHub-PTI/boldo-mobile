import 'dart:async';
import 'dart:isolate';
import 'package:boldo/constants.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/screens/Call/components/call_ended_popup.dart';
import 'package:boldo/screens/dashboard/tabs/appoinment_tab.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:intl/intl.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:boldo/screens/Call/video_call.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  TabController _tabController;

  Isolate _isolate;
  ReceivePort _receivePort;

  List<Appointment> futureAppointments = [];
  List<Appointment> pastAppointments = [];
  List<Appointment> upcomingWaitingRoomAppointments = [];
  List<Appointment> waitingRoomAppointments = [];

  bool _dataFetchError = false;
  bool _loading = true;

  int _selectedIndex = 0;

  String profileURL;
  String gender = "male";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await getAppointmentsData();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    getAppointmentsData();
    _getProfileData();
    _tabController.addListener(() {
      if (_tabController.index != _selectedIndex) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_isolate != null) {
      _isolate.kill(priority: Isolate.immediate);
      _isolate = null;
    }
    if (_receivePort != null) {
      _receivePort.close();
      _receivePort = null;
    }
    _tabController.dispose();
    super.dispose();
  }

  Future _getProfileData() async {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
    if (!isAuthenticated && !mounted) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      profileURL = prefs.getString("profile_url");
      gender = prefs.getString("gender");
    });
  }

  static void _updateWaitingRoomsList(Map map) async {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      for (Appointment appointment in map["upcomingWaitingRoomAppointments"]) {
        if (DateTime.now()
            .add(const Duration(minutes: 15))
            .isAfter(DateTime.parse(appointment.start).toLocal())) {
          timer.cancel();
          map['port'].send({"newAppointment": appointment});
          break;
        }
      }
    });
  }

  void _handleWaitingRoomsListUpdate(dynamic data) async {
    _isolate.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort.close();
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
        'port': _receivePort.sendPort,
        'upcomingWaitingRoomAppointments': updatedUpcomingAppointments,
      },
    );
    _receivePort.listen(_handleWaitingRoomsListUpdate);
  }

  Future<void> getAppointmentsData() async {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;

    if (_isolate != null) {
      _isolate.kill(priority: Isolate.immediate);
      _isolate = null;
    }
    if (_receivePort != null) {
      _receivePort.close();
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
    try {
      Response response = await dio.get("/profile/patient/appointments");

      List<Appointment> allAppointmets = List<Appointment>.from(
          response.data["appointments"].map((i) => Appointment.fromJson(i)));

      if (!mounted) return;

      List<Appointment> pastAppointmentsItems = allAppointmets
          .where((element) => ["closed", "locked"].contains(element.status))
          .toList();
      List<Appointment> upcomingAppointmentsItems = allAppointmets
          .where((element) => !["closed", "locked"].contains(element.status))
          .toList();

      pastAppointmentsItems.sort(
          (a, b) => DateTime.parse(b.start).compareTo(DateTime.parse(a.start)));

      upcomingAppointmentsItems.sort(
          (a, b) => DateTime.parse(a.start).compareTo(DateTime.parse(b.start)));

      List<Appointment> upcomingWaitingRoomAppointmetsList = allAppointmets
          .where((element) =>
              element.status == "upcoming" &&
              DateTime.now()
                  .add(const Duration(minutes: 15))
                  .isBefore(DateTime.parse(element.start).toLocal()))
          .toList();
      if (!mounted) return;
      _receivePort = ReceivePort();
      _isolate = await Isolate.spawn(
        _updateWaitingRoomsList,
        {
          'port': _receivePort.sendPort,
          'upcomingWaitingRoomAppointments': upcomingWaitingRoomAppointmetsList,
        },
      );
      _receivePort.listen(_handleWaitingRoomsListUpdate);
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
                    .isAfter(DateTime.parse(element.start).toLocal())) {
              return true;
            }
            return false;
          },
        ).toList();
        pastAppointments = pastAppointmentsItems;

        futureAppointments = upcomingAppointmentsItems;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasAppointments =
        pastAppointments.length != 0 || futureAppointments.length != 0;
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          leadingWidth: double.infinity,
          toolbarHeight: 110,
          flexibleSpace: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 30, left: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Selector<UserProvider, String>(
                    builder: (_, data, __) {
                      return SizedBox(
                        height: 60,
                        width: 60,
                        child: Card(
                          margin: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 9,
                          child: ClipOval(
                            clipBehavior: Clip.antiAlias,
                            child: data == null && profileURL == null
                                ? SvgPicture.asset(
                                    isAuthenticated
                                        ? gender == "female"
                                            ? 'assets/images/femalePatient.svg'
                                            : 'assets/images/malePatient.svg'
                                        : 'assets/images/LogoIcon.svg',
                                  )
                                : CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: data ?? profileURL,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Padding(
                                      padding: const EdgeInsets.all(26.0),
                                      child: CircularProgressIndicator(
                                        value: downloadProgress.progress,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Constants.primaryColor400),
                                        backgroundColor:
                                            Constants.primaryColor600,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                          ),
                        ),
                      );
                    },
                    selector: (buildContext, userProvider) =>
                        userProvider.getPhotoUrl,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hola!",
                        style: boldoHeadingTextStyle.copyWith(
                            fontSize: 24, color: Constants.primaryColor500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, dd MMMM')
                            .format(DateTime.now())
                            .capitalize(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  'Estamos para ayudarlo, ¿Qué deseas hacer?',
                  style: boldoSubTextStyle.copyWith(fontSize: 17),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: "/appoinment"),
                    builder: (context) => AppoinmentTab(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quiero agendar una consulta',
                            style: boldoHeadingTextStyle.copyWith(fontSize: 15),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  'Consulta médica de manera remota',
                                  style:
                                      boldoSubTextStyle.copyWith(fontSize: 13),
                                ),
                                const Spacer(),
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.phone_callback_outlined,
                                    color: Constants.primaryColor500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Sin consultas agendadas',
                              style: boldoSubTextStyle.copyWith(
                                  fontSize: 13,
                                  color: Constants.primaryColor500),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiero ver mis recetas médicas',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 15),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Lista de recetas asignadas al paciente',
                                style: boldoSubTextStyle.copyWith(fontSize: 13),
                              ),
                              const Spacer(),
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.description_outlined,
                                    color: Constants.secondaryColor500),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Notificación mas reciente',
                            style: boldoSubTextStyle.copyWith(
                                fontSize: 13,
                                color: Constants.secondaryColor500),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiero explorar registros clinicos',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 15),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Conjunto de datos clínicos del paciente',
                                style: boldoSubTextStyle.copyWith(fontSize: 13),
                              ),
                              const Spacer(),
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.assignment,
                                  color: Constants.primaryColor500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Resultados actualizados hace 2 dias',
                            style: boldoSubTextStyle.copyWith(
                                fontSize: 13, color: Constants.primaryColor500),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiero ver mis mediciones médicas',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 15),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Conjunto de dispositivos disponibles',
                                style: boldoSubTextStyle.copyWith(fontSize: 13),
                              ),
                              const Spacer(),
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.memory,
                                    color: Constants.secondaryColor500),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '1 dispositivo pendiente de devolución',
                            style: boldoSubTextStyle.copyWith(
                                fontSize: 13,
                                color: Constants.secondaryColor500),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ));
  }
}

class WaitingRoomCard extends StatelessWidget {
  final Appointment appointment;
  final Function() getAppointmentsData;
  const WaitingRoomCard(
      {Key key, @required this.appointment, @required this.getAppointmentsData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 24),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Sala de espera",
                    style: boldoHeadingTextStyle,
                  ),
                  const SizedBox(height: 3),
                  Text(
                      "La sala de espera de tu consulta con ${getDoctorPrefix(appointment.doctor.gender)}${appointment.doctor.familyName} ya se encuentra habilitada. ",
                      style: boldoSubTextStyle.copyWith(
                        height: 1.2,
                        fontSize: 15,
                      ))
                ]),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xffE5E7EB),
          ),
          Container(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextButton(
                      onPressed: () async {
                        final updateAppointments = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoCall(appointment: appointment),
                          ),
                        );

                        if (updateAppointments != null) {
                          if (updateAppointments["error"] != null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(updateAppointments["error"])));
                          }
                          if (updateAppointments["appointment"] != null) {
                            await callEndedPopup(
                                context: context,
                                appointment: updateAppointments["appointment"]);
                            getAppointmentsData();
                          } else if (updateAppointments["tokenError"] != null) {
                            //reload data
                            getAppointmentsData();
                            // show scnackbar
                            Scaffold.of(context).showSnackBar(const SnackBar(
                                content: Text(
                                    'Something went wrong! Please try again later.')));
                          }
                        }
                      },
                      child: Text(
                        'Ingresar',
                        style: boldoHeadingTextStyle.copyWith(
                            color: Constants.primaryColor500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataFetchErrorWidget extends StatelessWidget {
  final Function() retryCallback;
  const DataFetchErrorWidget({Key key, @required this.retryCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Ocurrió un error",
            style: TextStyle(
                color: Constants.otherColor100,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 17),
          Container(
            child: const Text(
              "Algo salió mal mientras cargaba tus datos",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Constants.extraColor300,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: retryCallback,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("Reintentar"),
            ),
          )
        ],
      ),
    );
  }
}
