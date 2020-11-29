import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../network/http.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/wrapper.dart';
import './booking_confirm_screen.dart';
import '../../constants.dart';
import '../../models/Doctor.dart';
import '../../utils/helpers.dart';

class BookingScreen extends StatefulWidget {
  BookingScreen({Key key, @required this.doctor}) : super(key: key);
  final Doctor doctor;
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _loading = true;
  bool _loadingCalendar = false;
  String nextAvailability;
  DateTime _selectedBookingHour;
  List<String> _availabilities = [];

  List<DateTime> _availabilitiesForDay = [];
  String _errorMessage = "";
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData(DateTime.now());
  }

  List<DateTime> findAvailabilitesForDay(
      List<String> allAvailabilites, DateTime day) {
    List<DateTime> availabilitiesForDay = [];
    for (String availability in allAvailabilites) {
      DateTime parsedAvailability = DateTime.parse(availability).toLocal();
      //we do this because we need to have a dateTime object with 00:00:00 HH:MM:SS for comparison
      DateTime dateWithOutHours = DateTime(parsedAvailability.year,
          parsedAvailability.month, parsedAvailability.day);

      if (dateWithOutHours == DateTime(day.year, day.month, day.day)) {
        availabilitiesForDay.add(DateTime.parse(availability).toLocal());
      }
    }
    availabilitiesForDay.sort((a, b) => a.compareTo(b));
    return availabilitiesForDay;
  }

  Future fetchData(DateTime date) async {
    try {
      Response response = await dio
          .get("/doctors/${widget.doctor.id}/availability", queryParameters: {
        'start': date.toIso8601String(),
        'end': DateTime(date.year, date.month + 1, 0).toIso8601String(),
      });
      List<String> allAvailabilities =
          response.data["availabilities"].cast<String>();
      setState(() {
        _availabilitiesForDay =
            findAvailabilitesForDay(allAvailabilities, date);
        _availabilities = allAvailabilities;
        nextAvailability = response.data["nextAvailability"];
        _loading = false;
        _loadingCalendar = false;
      });
    } on DioError catch (err) {
      print(err);
      setState(() {
        _errorMessage = "Something went wrong, please try again later.";
        _loading = false;
        _loadingCalendar = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _errorMessage = "Something went wrong, please try again later.";
        _loading = false;
        _loadingCalendar = false;
      });
    }
  }

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
        if (_loading) const Center(child: CircularProgressIndicator()),
        if (_errorMessage == "")
          Center(
            child: Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Constants.otherColor100,
              ),
            ),
          ),
        if (_loading == false && _errorMessage == "")
          Column(
            children: [
              if (nextAvailability != null)
                _BookDoctorCard(
                    doctor: widget.doctor, nextAvailability: nextAvailability),
              const SizedBox(
                height: 12,
              ),
              if (_loadingCalendar)
                const Center(child: CircularProgressIndicator()),
              if (!_loadingCalendar)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: _BookCalendar(
                          selectedDate: _selectedDate,
                          changeDateCallback: (DateTime newDate) {
                            if (DateTime(newDate.year, newDate.month) !=
                                DateTime(
                                    _selectedDate.year, _selectedDate.month)) {
                              setState(() {
                                _selectedBookingHour = null;
                                _loadingCalendar = true;
                                _selectedDate = newDate;
                              });
                              fetchData(newDate);

                              return;
                            }
                            setState(() {
                              _selectedBookingHour = null;
                              _availabilitiesForDay = findAvailabilitesForDay(
                                  _availabilities, newDate);
                              _selectedDate = newDate;
                            });
                          }),
                    ),
                    Center(
                      child: Text(
                        DateFormat('dd MMMM yyyy').format(_selectedDate),
                        style: boldoHeadingTextStyle.copyWith(
                            fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (_availabilitiesForDay.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "The doctor is not availible in this day.",
                          style: boldoHeadingTextStyle.copyWith(fontSize: 13),
                        ),
                      ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxWidth: 350,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 27,
                          children: [
                            ..._availabilitiesForDay
                                .map((e) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedBookingHour =
                                              _selectedBookingHour == e
                                                  ? null
                                                  : e;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: _selectedBookingHour == e
                                                ? Constants.primaryColor400
                                                : Constants.tertiaryColor100,
                                            borderRadius:
                                                BorderRadius.circular(9),
                                            border: Border.all(
                                                color: _selectedBookingHour == e
                                                    ? Constants.primaryColor600
                                                    : Constants.extraColor200)),
                                        width: 60,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            DateFormat('HH:mm').format(e),
                                            textAlign: TextAlign.center,
                                            style:
                                                boldoHeadingTextStyle.copyWith(
                                                    fontSize: 14,
                                                    color:
                                                        _selectedBookingHour ==
                                                                e
                                                            ? Colors.white
                                                            : Constants
                                                                .extraColor400),
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
                                      bookingDate: _selectedBookingHour,
                                      doctor: widget.doctor,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: const Text("Aceptar"),
                      ),
                    )
                  ],
                ),
            ],
          ),
      ],
    );
  }
}

class _BookCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime changeDateCallback) changeDateCallback;
  const _BookCalendar(
      {Key key, @required this.selectedDate, @required this.changeDateCallback})
      : super(key: key);

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
            selectedDate: selectedDate, changeDateCallback: changeDateCallback),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}

class _BookDoctorCard extends StatelessWidget {
  const _BookDoctorCard(
      {Key key, @required this.doctor, @required this.nextAvailability})
      : super(key: key);

  final String nextAvailability;
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    String availabilityText = "";
    bool isToday = false;

    DateTime parsedAvailability = DateTime.parse(nextAvailability).toLocal();
    int daysDifference = parsedAvailability.difference(DateTime.now()).inDays;

    isToday = daysDifference == 0;

    if (isToday) {
      availabilityText = "Disponible Hoy!";
    } else if (daysDifference > 0) {
      availabilityText =
          "Disponible ${DateFormat('EEEE, dd MMMM').format(parsedAvailability)}";
    }

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
                          availabilityText,
                          style: boldoHeadingTextStyle.copyWith(
                            fontSize: 14,
                            color: isToday
                                ? Constants.primaryColor600
                                : Constants.secondaryColor500,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          DateFormat('EEEE, dd MMMM')
                              .format(parsedAvailability)
                              .capitalize(),
                          style: boldoSubTextStyle,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          "${DateFormat('HH:mm').format(parsedAvailability)} horas",
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
                      bookingDate: parsedAvailability,
                      doctor: doctor,
                    ),
                  ),
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
