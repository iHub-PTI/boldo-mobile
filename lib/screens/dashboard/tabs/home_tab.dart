import 'dart:async';
import 'dart:isolate';

import 'package:boldo/provider/user_provider.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:boldo/screens/call/video_call.dart';
import 'package:boldo/screens/dashboard/tabs/components/appointment_card.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../network/http.dart';
import '../../../constants.dart';
import '../../../provider/auth_provider.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Isolate _isolate;
  ReceivePort _receivePort;

  List<Appointment> futureAppointments = [];
  List<Appointment> pastAppointments = [];
  List<Appointment> upcomingWaitingRoomAppointments = [];
  List<Appointment> waitingRoomAppointments = [];

  bool _dataFetchError = false;
  bool _loading = true;
  bool _mounted;

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
    _mounted = true;
    getAppointmentsData();
    _getProfileData();
    super.initState();
  }

  @override
  void dispose() {
    _mounted = false;
    if (_isolate != null) {
      _receivePort.close();
      _isolate.kill(priority: Isolate.immediate);
    }
    super.dispose();
  }

  Future _getProfileData() async {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
    if (!isAuthenticated) return;
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
    setState(() {
      _loading = true;
      _dataFetchError = false;
    });
    try {
      Response response = await dio.get("/profile/patient/appointments");
      print(response);
      List<Appointment> allAppointmets = List<Appointment>.from(
          response.data.map((i) => Appointment.fromJson(i)));

      if (!_mounted) return;

      List<Appointment> pastAppointmentsItems = allAppointmets
          .where((element) => element.status == "closed")
          .toList();
      List<Appointment> upcomingAppointmentsItems = allAppointmets
          .where((element) => element.status != "closed")
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
      if (!_mounted) return;
      _receivePort = ReceivePort();
      _isolate = await Isolate.spawn(
        _updateWaitingRoomsList,
        {
          'port': _receivePort.sendPort,
          'upcomingWaitingRoomAppointments': upcomingWaitingRoomAppointmetsList,
        },
      );
      _receivePort.listen(_handleWaitingRoomsListUpdate);
      if (!_mounted) return;
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
    } on DioError catch (err) {
      print(err);
      setState(() {
        _loading = false;
        _dataFetchError = true;
      });
    } catch (err) {
      print(err);

      setState(() {
        _loading = false;
        _dataFetchError = false;
      });
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
            margin: const EdgeInsets.only(top: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return SizedBox(
                      height: 60,
                      width: 60,
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
                                    (context, url, downloadProgress) => Padding(
                                  padding: const EdgeInsets.all(26.0),
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                      ),
                    );
                  },
                  selector: (buildContext, userProvider) =>
                      userProvider.getPhotoUrl,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "¡Bienvenido!",
                      style: boldoHeadingTextStyle.copyWith(
                          fontSize: 24, color: Constants.primaryColor500),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const Text("Lunes, 14 de septiembre"),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: _dataFetchError
          ? DataFetchErrorWidget(retryCallback: getAppointmentsData)
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : !isAuthenticated || !hasAppointments
                  ? const EmptyAppointmentsState(size: "big")
                  : DefaultTabController(
                      length: 2,
                      child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: false,
                        header: const MaterialClassicHeader(
                          color: Constants.primaryColor800,
                        ),
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        child: CustomScrollView(slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                for (Appointment appointment
                                    in waitingRoomAppointments)
                                  WaitingRoomCard(appointment: appointment),
                              ],
                            ),
                          ),
                          const SliverAppBar(
                            automaticallyImplyLeading: false,
                            pinned: true,
                            flexibleSpace: TabBar(
                              labelColor: Constants.primaryColor600,
                              unselectedLabelColor: Constants.extraColor300,
                              indicatorColor: Constants.primaryColor600,
                              labelStyle: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              tabs: [
                                Tab(
                                  text: "Próximas Citas",
                                ),
                                Tab(
                                  text: "Citas Pasadas",
                                ),
                              ],
                            ),
                            elevation: 0,
                          ),
                          SliverFillRemaining(
                            child: TabBarView(
                              children: <Widget>[
                                futureAppointments.length > 0
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 24.0),
                                        child: ListView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            for (Appointment appointment
                                                in futureAppointments)
                                              AppointmentCard(
                                                appointment: appointment,
                                              ),
                                          ],
                                        ),
                                      )
                                    : const Center(
                                        child: EmptyAppointmentsState(
                                            size: "small"),
                                      ),
                                pastAppointments.length > 0
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          top: 24.0,
                                        ),
                                        child: ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: pastAppointments.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return AppointmentCard(
                                              appointment:
                                                  pastAppointments[index],
                                            );
                                          },
                                        ),
                                      )
                                    : const Center(
                                        child: EmptyAppointmentsState(
                                            size: "small"),
                                      )
                              ],
                            ),
                          )
                        ]),
                      ),
                    ),
    );
  }
}

class WaitingRoomCard extends StatelessWidget {
  final Appointment appointment;
  const WaitingRoomCard({Key key, @required this.appointment})
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
            height: 105,
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Sala de espera",
                    style: boldoHeadingTextStyle,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                      "La sala de espera de tu consulta con Dr. House ya se encuentra habilitada. ",
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
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoCall(appointmentId: appointment.id),
                            ));
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
            "An error occured",
            style: TextStyle(
                color: Constants.otherColor100,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 17,
          ),
          Container(
            child: const Text(
              "Somethign went wrong while fetching your data",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Constants.extraColor300,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: retryCallback,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("Retry"),
            ),
          )
        ],
      ),
    );
  }
}
