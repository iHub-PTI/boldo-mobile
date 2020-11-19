import 'package:boldo/constants.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsTabBar extends StatefulWidget {
  final List<Appointment> upcomingAppointments;
  final List<Appointment> pastAppointments;
  AppointmentsTabBar(
      {Key key,
      @required this.upcomingAppointments,
      @required this.pastAppointments})
      : super(key: key);

  @override
  _AppointmentsTabBarState createState() => _AppointmentsTabBarState();
}

class _AppointmentsTabBarState extends State<AppointmentsTabBar>
    with SingleTickerProviderStateMixin {
  TabController nestedTabController;

  @override
  void dispose() {
    nestedTabController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nestedTabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.upcomingAppointments);
    print(widget.pastAppointments);
    return Column(
      children: [
        TabBar(
          labelColor: Constants.primaryColor600,
          unselectedLabelColor: Constants.extraColor300,
          indicatorColor: Constants.primaryColor600,
          labelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          controller: nestedTabController,
          tabs: [
            const Tab(
              text: "Próximas Citas",
            ),
            const Tab(
              text: "Citas Pasadas",
            ),
          ],
        ),
        Container(height: 1, color: Constants.extraColor200),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: TabBarView(
              controller: nestedTabController,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24.0,
                  ),
                  child: ListView(
                    children: [
                      for (Appointment appointment
                          in widget.upcomingAppointments)
                        AppointmentCard(
                          appointment: appointment,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24.0,
                  ),
                  child: ListView.builder(
                    itemCount: widget.pastAppointments.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AppointmentCard(
                        appointment: widget.pastAppointments[index],
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({
    Key key,
    @required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int daysDifference =
        DateTime.parse(appointment.start).difference(DateTime.now()).inDays;
    bool isPast = DateTime.parse(appointment.start).isBefore(DateTime.now());

    return Card(
      elevation: 1.4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
      child: Row(
        children: [
          Container(
            height: 96,
            width: 64,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
              color: daysDifference == 0 && !isPast
                  ? Constants.primaryColor500
                  : Constants.tertiaryColor200,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM').format(DateTime.parse(appointment.start)),
                  style: TextStyle(
                    color: daysDifference == 0 && !isPast
                        ? Constants.extraColor100
                        : Constants.primaryColor500,
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateFormat('dd').format(DateTime.parse(appointment.start)),
                  style: TextStyle(
                    color: daysDifference == 0 && !isPast
                        ? Constants.extraColor100
                        : Constants.primaryColor500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dr. Gregory House",
                style: TextStyle(
                  color: Constants.extraColor400,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                "Clínico General",
                style: TextStyle(
                  color: Constants.extraColor300,
                  fontSize: 14,
                ),
              ),
              if (daysDifference == 0 && !isPast)
                Column(
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    const Text(
                      "¡Hoy!",
                      style: TextStyle(
                        color: Constants.primaryColor600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              if (daysDifference > 0)
                Column(
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "En $daysDifference días",
                      style: const TextStyle(
                        color: Constants.otherColor200,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          )
        ],
      ),
    );
  }
}
