import 'dart:async';
import 'package:boldo/constants.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/provider/utils_provider.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:intl/intl.dart';
import 'package:boldo/provider/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Appointment> futureAppointments = [];
  List<Appointment> pastAppointments = [];
  List<Appointment> upcomingWaitingRoomAppointments = [];
  List<Appointment> waitingRoomAppointments = [];

  int _selectedIndex = 0;

  String profileURL;
  String name;
  String gender = "male";

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
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
      name = prefs.getString("name");
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        "Hola ${name != null ? name.toLowerCase().substring(0, name.indexOf(' ')) : ''}!",
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
            const SizedBox(height: 20),
            //Appoinment
            GestureDetector(
              onTap: () async {
                final _result =
                    await Navigator.pushNamed(context, '/appointment');
                if (_result == true) {
                  Provider.of<UtilsProvider>(context, listen: false)
                      .setSelectedPageIndex(pageIndex: 1);
                }
              },
              child: Card(
                elevation: 1.4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiero agendar una consulta',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Consulta médica de manera remota',
                          style: boldoSubTextStyle.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Próxima consulta en 3 dias',
                          style: boldoSubTextStyle.copyWith(
                              fontSize: 13, color: Constants.primaryColor500),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      height: 105,
                      width: 70,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                          ),
                          color: Constants.primaryColor50),
                      child: const Icon(
                        Icons.phone_callback_outlined,
                        color: Constants.primaryColor500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //END

            // Prescriptions
            GestureDetector(
              onTap: () {},
              child: Card(
                elevation: 1.4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiero ver mis recetas médicas',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Lista de recetas asignadas al paciente',
                          style: boldoSubTextStyle.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Notificación mas reciente',
                          style: boldoSubTextStyle.copyWith(
                              fontSize: 13, color: Constants.secondaryColor500),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      height: 105,
                      width: 70,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                          ),
                          color: Constants.secondaryColor50),
                      child: const Icon(Icons.description_outlined,
                          color: Constants.secondaryColor500),
                    ),
                  ],
                ),
              ),
            ),
            //End

            //Clinical record
            GestureDetector(
              onTap: () {},
              child: Card(
                elevation: 1.4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiero explorar registros clínicos',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Conjunto de datos clínicos del paciente',
                          style: boldoSubTextStyle.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Resultados actualizados hace 2 días',
                          style: boldoSubTextStyle.copyWith(
                              fontSize: 13, color: Constants.primaryColor500),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      height: 105,
                      width: 70,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                          ),
                          color: Constants.primaryColor50),
                      child: const Icon(
                        Icons.assignment,
                        color: Constants.primaryColor500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //END

            // Medical Measurements
            GestureDetector(
              onTap: () {},
              child: Card(
                elevation: 1.4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiero ver mis mediciones médicas',
                          style: boldoHeadingTextStyle.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Conjunto de dispositivos disponibles',
                          style: boldoSubTextStyle.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '1 dispositivo pendiente de devolución',
                          style: boldoSubTextStyle.copyWith(
                              fontSize: 13, color: Constants.secondaryColor500),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      height: 105,
                      width: 70,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                          ),
                          color: Constants.secondaryColor50),
                      child: const Icon(Icons.memory,
                          color: Constants.secondaryColor500),
                    ),
                  ],
                ),
              ),
            ),
            //End
          ],
        ));
  }
}
