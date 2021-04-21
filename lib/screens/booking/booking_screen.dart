import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:boldo/models/CalendarItem.dart';
import 'package:boldo/widgets/calendar/utils/month_builder.dart';
import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/widgets/register_popup.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
  bool notAvailibleThisMonth = false;
  String nextAvailability;
  DateTime _selectedBookingHour;
  List<DateTime> _availabilities = [];

  List<List<CalendarItem>> chunkArrays = [];
  List<DateTime> _availabilitiesForDay = [];
  String _errorMessage = "";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData(DateTime.now());
  }

  Future<void> handleBookingHour({DateTime bookingHour}) async {
    bool isAuthenticated =
        Provider.of<AuthProvider>(context, listen: false).getAuthenticated;
    if (!isAuthenticated) {
      await notLoggedInPop(context: context);

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmScreen(
          bookingDate: bookingHour ?? _selectedBookingHour,
          doctor: widget.doctor,
        ),
      ),
    );
  }

  List<DateTime> findAvailabilitesForDay(
      List<DateTime> allAvailabilites, DateTime day) {
    List<DateTime> availabilitiesForDay = [];
    for (DateTime availability in allAvailabilites) {
      //we do this because we need to have a dateTime object with 00:00:00 HH:MM:SS for comparison
      DateTime dateWithOutHours =
          DateTime(availability.year, availability.month, availability.day);

      if (dateWithOutHours == DateTime(day.year, day.month, day.day)) {
        availabilitiesForDay.add(availability);
      }
    }
    availabilitiesForDay.sort((a, b) => a.compareTo(b));
    return availabilitiesForDay;
  }

  List<DateTime> convertToDateTime(List<String> allAvailabilites) {
    List<DateTime> availabilitiesForDay = [];
    for (String availability in allAvailabilites) {
      DateTime parsedAvailability = DateTime.parse(availability).toLocal();

      availabilitiesForDay.add(parsedAvailability);
    }
    availabilitiesForDay.sort((a, b) => a.compareTo(b));
    return availabilitiesForDay;
  }

  Future fetchData(DateTime date) async {
    // Fixme: When appoinment is cancelled, the user need to have the capatibilty to create a new one
    // in the same hour where was cancelled.. that's no possible now, because this endpoint don't bring
    // again the hour for make a new appoinment.
    try {
      Response response = await dio
          .get("/doctors/${widget.doctor.id}/availability", queryParameters: {
        'start': date.toUtc().toIso8601String(),
        'end': DateTime(date.year, date.month + 1, 1).toUtc().toIso8601String(),
      });
      List<String> allAvailabilities =
          response.data["availabilities"].cast<String>();
      List<DateTime> allAvailabilitesDateTime =
          convertToDateTime(allAvailabilities);

      List<List<CalendarItem>> _chunkArrays = monthBuilder(
          buildDate: date, allAvailabilities: allAvailabilitesDateTime);

      bool noAvailibilityThisMonth = true;
      DateTime firstDay = date;
      for (List<CalendarItem> chunkArray in _chunkArrays) {
        CalendarItem notEmptyCalendarItem = chunkArray.firstWhere(
            (element) =>
                element.isEmpty == false && element.isDisabled == false,
            orElse: () => null);
        if (notEmptyCalendarItem != null) {
          noAvailibilityThisMonth = false;
          firstDay = notEmptyCalendarItem.itemDate;
          break;
        }
      }

      setState(() {
        chunkArrays = _chunkArrays;
        notAvailibleThisMonth = noAvailibilityThisMonth;
        _availabilitiesForDay = noAvailibilityThisMonth
            ? []
            : findAvailabilitesForDay(allAvailabilitesDateTime, firstDay);
        _availabilities = allAvailabilitesDateTime;
        nextAvailability = response.data["nextAvailability"];
        selectedDate = firstDay;
        _loading = false;
        _loadingCalendar = false;
      });
    } on DioError catch (exception, stackTrace) {
      print(exception);
      setState(() {
        _errorMessage =
            "Algo salió mal. Por favor, inténtalo de nuevo más tarde.";
        _loading = false;
        _loadingCalendar = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (exception, stackTrace) {
      print(exception);
      setState(() {
        _errorMessage =
            "Algo salió mal. Por favor, inténtalo de nuevo más tarde.";
        _loading = false;
        _loadingCalendar = false;
      });
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      children: [
        const SizedBox(height: 20),
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
        if (_loading)
          const Center(
              child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
            backgroundColor: Constants.primaryColor600,
          )),
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
                  doctor: widget.doctor,
                  nextAvailability: nextAvailability,
                  handleBookingHour: (date) =>
                      handleBookingHour(bookingHour: date),
                ),
              const SizedBox(height: 12),
              if (_loadingCalendar)
                const Center(
                    child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                  backgroundColor: Constants.primaryColor600,
                )),
              if (!_loadingCalendar)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: _BookCalendar(
                          chunkArrays: chunkArrays,
                          notAvailibleThisMonth: notAvailibleThisMonth,
                          selectedDate: selectedDate,
                          changeDateCallback: (DateTime newDate) async {
                            if (DateTime(newDate.year, newDate.month) !=
                                DateTime(
                                    selectedDate.year, selectedDate.month)) {
                              setState(() {
                                _selectedBookingHour = null;
                                _loadingCalendar = true;
                                selectedDate = newDate;
                              });

                              await fetchData(newDate);

                              return;
                            }

                            setState(() {
                              _selectedBookingHour = null;
                              _availabilitiesForDay = findAvailabilitesForDay(
                                  _availabilities, newDate);
                              selectedDate = newDate;
                            });
                          }),
                    ),
                    if (!notAvailibleThisMonth)
                      Column(children: [
                        Center(
                          child: Text(
                            DateFormat('dd MMMM yyyy').format(selectedDate),
                            style: boldoHeadingTextStyle.copyWith(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_availabilitiesForDay.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              "No hay disponibilidad en esta fecha",
                              style:
                                  boldoHeadingTextStyle.copyWith(fontSize: 13),
                            ),
                          ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 350),
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
                                                color:
                                                    _selectedBookingHour == e
                                                        ? Constants
                                                            .primaryColor400
                                                        : Constants
                                                            .tertiaryColor100,
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                border: Border.all(
                                                    color:
                                                        _selectedBookingHour ==
                                                                e
                                                            ? Constants
                                                                .primaryColor600
                                                            : Constants
                                                                .extraColor200)),
                                            width: 60,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                DateFormat('HH:mm').format(e),
                                                textAlign: TextAlign.center,
                                                style: boldoHeadingTextStyle.copyWith(
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
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          margin: const EdgeInsets.only(bottom: 16),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Constants.primaryColor500,
                            ),
                            onPressed: _selectedBookingHour != null
                                ? handleBookingHour
                                : null,
                            child: const Text("Aceptar"),
                          ),
                        )
                      ]),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}

class _BookCalendar extends StatelessWidget {
  final List<List<CalendarItem>> chunkArrays;
  final bool notAvailibleThisMonth;
  final DateTime selectedDate;
  final Function(DateTime changeDateCallback) changeDateCallback;

  const _BookCalendar({
    Key key,
    @required this.chunkArrays,
    @required this.notAvailibleThisMonth,
    @required this.selectedDate,
    @required this.changeDateCallback,
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
        const SizedBox(height: 20),
        CustomCalendar(
          calendarItems: chunkArrays,
          notAvailibleThisMonth: notAvailibleThisMonth,
          selectedDate: selectedDate,
          changeDateCallback: changeDateCallback,
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}

class _BookDoctorCard extends StatelessWidget {
  const _BookDoctorCard(
      {Key key,
      @required this.doctor,
      @required this.nextAvailability,
      @required this.handleBookingHour})
      : super(key: key);
  final Function(DateTime) handleBookingHour;
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
                handleBookingHour(parsedAvailability);
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
