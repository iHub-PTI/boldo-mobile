import 'package:boldo/models/Appointment.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/screens/call/video_call.dart';
import 'package:boldo/screens/dashboard/tabs/components/appointments_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import '../../../provider/auth_provider.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

var fakeAppintment = [
  {
    "id": "1",
    "start": "2020-01-23T17:00:00.000-0300",
    "end": "2020-01-23T17:30:00.000-0300",
    "description": "A nice description",
    "doctor": {
      "addressDescription": "A dos cuadras de la comisaria septima",
      "birthDate": "1992-04-08",
      "city": "Ciudad del Este",
      "email": "cecilia.casco7@gmail.com",
      "familyName": "Casco",
      "gender": "female",
      "givenName": "Cecilia",
      "id": "2",
      "identifier": "3915577",
      "job": "Software Engineer",
      "neighborhood": "San Jose",
      "phone": "0975773655",
      "photoUrl": "http://photourl/photo.jpeg",
      "street": "San Vicente"
    }
  },
  {
    "id": "2",
    "start": "2020-02-01T17:00:00.000-0300",
    "end": "2020-02-01T17:30:00.000-0300",
    "description": "A nice description",
    "doctor": {
      "addressDescription": "A dos cuadras de la comisaria septima",
      "birthDate": "1992-04-08",
      "city": "Ciudad del Este",
      "email": "cecilia.casco7@gmail.com",
      "familyName": "Casco",
      "gender": "female",
      "givenName": "Cecilia",
      "id": "2",
      "identifier": "3915577",
      "job": "Software Engineer",
      "neighborhood": "San Jose",
      "phone": "0975773655",
      "photoUrl": "http://photourl/photo.jpeg",
      "street": "San Vicente"
    }
  },
  {
    "id": "3",
    "start": "2020-03-11T17:00:00.000-0300",
    "end": "2020-03-11T17:30:00.000-0300",
    "description": "A nice description",
    "doctor": {
      "addressDescription": "A dos cuadras de la comisaria septima",
      "birthDate": "1992-04-08",
      "city": "Ciudad del Este",
      "email": "cecilia.casco7@gmail.com",
      "familyName": "Casco",
      "gender": "female",
      "givenName": "Cecilia",
      "id": "2",
      "identifier": "3915577",
      "job": "Software Engineer",
      "neighborhood": "San Jose",
      "phone": "0975773655",
      "photoUrl": "http://photourl/photo.jpeg",
      "street": "San Vicente"
    }
  },
  {
    "id": "4",
    "start": "2020-04-02T17:00:00.000-0300",
    "end": "2020-04-02T17:30:00.000-0300",
    "description": "A nice description",
    "doctor": {
      "addressDescription": "A dos cuadras de la comisaria septima",
      "birthDate": "1992-04-08",
      "city": "Ciudad del Este",
      "email": "cecilia.casco7@gmail.com",
      "familyName": "Casco",
      "gender": "female",
      "givenName": "Cecilia",
      "id": "2",
      "identifier": "3915577",
      "job": "Software Engineer",
      "neighborhood": "San Jose",
      "phone": "0975773655",
      "photoUrl": "http://photourl/photo.jpeg",
      "street": "San Vicente"
    }
  },
  {
    "id": "5",
    "start": "2020-11-18T17:00:00.000-0300",
    "end": "2020-11-18T17:30:00.000-0300",
    "description": "A nice description",
    "doctor": {
      "addressDescription": "A dos cuadras de la comisaria septima",
      "birthDate": "1992-04-08",
      "city": "Ciudad del Este",
      "email": "cecilia.casco7@gmail.com",
      "familyName": "Casco",
      "gender": "female",
      "givenName": "Cecilia",
      "id": "2",
      "identifier": "3915577",
      "job": "Software Engineer",
      "neighborhood": "San Jose",
      "phone": "0975773655",
      "photoUrl": "http://photourl/photo.jpeg",
      "street": "San Vicente"
    }
  },
  {
    "id": "6",
    "start": "2020-12-22T17:00:00.000-0300",
    "end": "2020-12-22T17:30:00.000-0300",
    "description": "A nice description",
    "doctor": {
      "addressDescription": "A dos cuadras de la comisaria septima",
      "birthDate": "1992-04-08",
      "city": "Ciudad del Este",
      "email": "cecilia.casco7@gmail.com",
      "familyName": "Casco",
      "gender": "female",
      "givenName": "Cecilia",
      "id": "2",
      "identifier": "3915577",
      "job": "Software Engineer",
      "neighborhood": "San Jose",
      "phone": "0975773655",
      "photoUrl": "http://photourl/photo.jpeg",
      "street": "San Vicente"
    }
  },
  {
    "id": "7",
    "start": "2020-11-04T17:00:00.000-0300",
    "end": "2020-11-04T17:30:00.000-0300",
    "description": "A nice description",
    "doctor": {
      "addressDescription": "A dos cuadras de la comisaria septima",
      "birthDate": "1992-04-08",
      "city": "Ciudad del Este",
      "email": "cecilia.casco7@gmail.com",
      "familyName": "Casco",
      "gender": "female",
      "givenName": "Cecilia",
      "id": "2",
      "identifier": "3915577",
      "job": "Software Engineer",
      "neighborhood": "San Jose",
      "phone": "0975773655",
      "photoUrl": "http://photourl/photo.jpeg",
      "street": "San Vicente"
    }
  }
];

class _HomeTabState extends State<HomeTab> {
  List<Appointment> upcomingAppointments = [];
  List<Appointment> pastAppointments = [];

  bool _loading = true;
  bool _mounted;

  @override
  void initState() {
    _mounted = true;
    _getAppointments();
    super.initState();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _getAppointments() async {
    //await Future.delayed(const Duration(seconds: 2));
    if (!_mounted) return;
    List<Appointment> allAppointmets =
        fakeAppintment.map((e) => Appointment.fromJson(e)).toList();

    List<Appointment> pastAppointmentsItems = allAppointmets
        .where((element) => DateTime.now().isAfter(DateTime.parse(element.end)))
        .toList();
    List<Appointment> upcomingAppointmentsItems = allAppointmets
        .where(
            (element) => DateTime.now().isBefore(DateTime.parse(element.end)))
        .toList();
    pastAppointmentsItems.sort(
        (a, b) => DateTime.parse(b.start).compareTo(DateTime.parse(a.start)));

    upcomingAppointmentsItems.sort(
        (a, b) => DateTime.parse(a.start).compareTo(DateTime.parse(b.start)));
    setState(() {
      _loading = false;
      pastAppointments = pastAppointmentsItems;
      upcomingAppointments = upcomingAppointmentsItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasAppointments =
        pastAppointments.length != 0 && upcomingAppointments.length != 0;
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
                SizedBox(
                  height: 60,
                  width: 60,
                  child: SvgPicture.asset(
                    isAuthenticated
                        ? 'assets/images/DoctorImage.svg'
                        : 'assets/images/LogoIcon.svg',
                  ),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !isAuthenticated || !hasAppointments
              ? const EmptyAppointmentsState()
              : Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(children: [
                    const AppointmentsCard(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: AppointmentsTabBar(
                            upcomingAppointments: upcomingAppointments,
                            pastAppointments: pastAppointments),
                      ),
                    )
                  ]),
                ),
    );
  }
}

class EmptyAppointmentsState extends StatelessWidget {
  const EmptyAppointmentsState({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/calendar.svg',
          ),
          const Text(
            "Agrega tu primera cita",
            style: TextStyle(
                color: Constants.extraColor400,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 17,
          ),
          Container(
            child: const Text(
              "Consulta la lista de doctores y \n programá tu primera cita",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Constants.extraColor300,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<UtilsProvider>(context, listen: false)
                  .setSelectedPageIndex(pageIndex: 1);
            },
            child: const Text("Agregar Cita"),
          )
        ],
      ),
    );
  }
}

class AppointmentsCard extends StatelessWidget {
  const AppointmentsCard({Key key}) : super(key: key);

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
                        String appointmentId = "1";
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoCall(appointmentId: appointmentId),
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
