import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/calendar/calendar.dart';
import '../../widgets/wrapper.dart';
import './booking_confirm_screen.dart';
import '../../constants.dart';

class BookingScreen extends StatefulWidget {
  BookingScreen({Key key}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _selectedBookingHour;
  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      children: [
        const SizedBox(
          height: 20,
        ),
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
            'Reservar',
            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const _BookDoctorCard(),
        const SizedBox(
          height: 12,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: _BookCalendar(),
        ),
        Center(
          child: Text(
            "14 de septiembre del 2020",
            style: boldoHeadingTextStyle.copyWith(
                fontWeight: FontWeight.normal, fontSize: 14),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 350,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 13,
              runSpacing: 27,
              children: [
                ...[
                  "08:00",
                  "08:20",
                  "08:40",
                  "08:45",
                  "09:20",
                  "09:40",
                  "10:40",
                  "11:00",
                  "11:20",
                  "13:20",
                  "14:40",
                  '15:00'
                ]
                    .map((e) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBookingHour =
                                  _selectedBookingHour == e ? null : e;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: _selectedBookingHour == e
                                    ? Constants.primaryColor400
                                    : Constants.tertiaryColor100,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                    color: _selectedBookingHour == e
                                        ? Constants.primaryColor600
                                        : Constants.extraColor200)),
                            width: 60,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                e,
                                textAlign: TextAlign.center,
                                style: boldoHeadingTextStyle.copyWith(
                                    fontSize: 14,
                                    color: _selectedBookingHour == e
                                        ? Colors.white
                                        : Constants.extraColor400),
                              ),
                            ),
                          ),
                        ))
                    .toList()
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          margin: const EdgeInsets.only(bottom: 16),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Constants.primaryColor500,
            ),
            onPressed: _selectedBookingHour != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingConfirmScreen(
                                bookingDate: DateTime.now(),
                                bookingHour: _selectedBookingHour,
                              )),
                    );
                  }
                : null,
            child: const Text("Aceptar"),
          ),
        )
      ],
    );
  }
}

class _BookCalendar extends StatelessWidget {
  const _BookCalendar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Más fechas',
          style: boldoHeadingTextStyle,
        ),
        const SizedBox(
          height: 20,
        ),
        CustomCalendar(
          selectedDate: DateTime.now(),
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}

class _BookDoctorCard extends StatelessWidget {
  const _BookDoctorCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 96,
            padding: const EdgeInsets.only(top: 18, right: 19, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: SvgPicture.asset('assets/icon/clockIcon.svg',
                        semanticsLabel: 'Clock Icon'),
                  ),
                ),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Disponible Hoy!",
                          style: boldoHeadingTextStyle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const Text(
                          "Lunes 7 de septiembre",
                          style: boldoSubTextStyle,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const Text(
                          "14:30 horas",
                          style: boldoSubTextStyle,
                        ),
                      ],
                    ),
                    flex: 5),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 52,
            decoration: const BoxDecoration(
              color: Constants.tertiaryColor100,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookingConfirmScreen(
                            bookingDate: DateTime.now(),
                            bookingHour: "14:30",
                          )),
                );
              },
              child: Text(
                'Reservar ahora',
                style: boldoHeadingTextStyle.copyWith(
                    color: Constants.primaryColor500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
