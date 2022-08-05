import 'package:boldo/screens/dashboard/tabs/doctors_tab.dart';
import 'package:boldo/widgets/in-person-virtual-switch.dart';
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
  BookingScreen({Key? key, required this.doctor}) : super(key: key);
  final Doctor doctor;
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _loading = true;
  bool _loadingCalendar = false;
  bool notAvailibleThisMonth = false;
  NextAvailability? nextAvailability;
  NextAvailability? _selectedBookingHour;
  List<AppoinmentWithDateAndType> _availabilities = [];
  String _typeAppoinmentSelected = 'A';
  List<List<CalendarItem>> chunkArrays = [];
  List<AppoinmentWithDateAndType> _availabilitiesForDay = [];
  String _errorMessage = "";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData(DateTime.now());
  }

  Future<void> handleBookingHour({NextAvailability? bookingHour}) async {
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
          bookingDate: bookingHour ?? _selectedBookingHour!,
          doctor: widget.doctor,
        ),
      ),
    );
  }

  List<AppoinmentWithDateAndType> findAvailabilitesForDay(
      List<AppoinmentWithDateAndType> allAvailabilites, DateTime day) {
    List<AppoinmentWithDateAndType> availabilitiesForDay = [];
    for (AppoinmentWithDateAndType availability in allAvailabilites) {
      //we do this because we need to have a dateTime object with 00:00:00 HH:MM:SS for comparison
      DateTime dateWithOutHours = DateTime(availability.dateTime.year,
          availability.dateTime.month, availability.dateTime.day);

      if (dateWithOutHours == DateTime(day.year, day.month, day.day)) {
        availabilitiesForDay.add(AppoinmentWithDateAndType(
            dateTime: availability.dateTime,
            appoinmentType: availability.appoinmentType));
      }
    }
    availabilitiesForDay.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return availabilitiesForDay;
  }

  List<AppoinmentWithDateAndType> convertToDateTime(
      List<NextAvailability> allAvailabilites) {
    List<AppoinmentWithDateAndType> availabilitiesForDay = [];
    for (NextAvailability availability in allAvailabilites) {
      DateTime parsedAvailability =
          DateTime.parse(availability.availability!).toLocal();

      availabilitiesForDay.add(AppoinmentWithDateAndType(
          dateTime: parsedAvailability,
          appoinmentType: availability.appointmentType!));
    }
    availabilitiesForDay.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return availabilitiesForDay;
  }

  Future fetchData(DateTime date) async {
    try {
      Response response = await dio
          .get("/doctors/${widget.doctor.id}/availability", queryParameters: {
        'start': date.toLocal().toIso8601String(),
        'end': DateTime(date.year, date.month + 1, 1).toLocal().toIso8601String(),
      });

      List<NextAvailability>? allAvailabilities = [];
      response.data['availabilities'].forEach((v) {
        allAvailabilities.add(NextAvailability.fromJson(v));
      });

      List<AppoinmentWithDateAndType> allAvailabilitesDateTime =
          convertToDateTime(allAvailabilities);

      List<List<CalendarItem>> _chunkArrays = monthBuilder(
          buildDate: date, allAvailabilities: allAvailabilitesDateTime);

      bool noAvailibilityThisMonth = true;
      DateTime firstDay = date;
      for (List<CalendarItem> chunkArray in _chunkArrays) {
        CalendarItem? notEmptyCalendarItem = chunkArray.firstWhere(
            (element) =>
                element.isEmpty == false && element.isDisabled == false,
            orElse: () => CalendarItem());
        if (notEmptyCalendarItem.itemDate != null) {
          noAvailibilityThisMonth = false;
          firstDay = notEmptyCalendarItem.itemDate!;
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
        if (response.data['nextAvailability'] != null) {
          nextAvailability =
              NextAvailability.fromJson(response.data["nextAvailability"]);
        }
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
            'Agendar',
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
                  nextAvailability: nextAvailability!.availability!,
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
                            DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(selectedDate),
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
                        VirtualInPersonSwitch(
                          switchCallbackResponse: (String text) {
                            setState(() {
                              _typeAppoinmentSelected = text;
                              _selectedBookingHour = null;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
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
                                    .map(
                                      (e) => _typeAppoinmentSelected ==
                                                  e.appoinmentType ||
                                              e.appoinmentType == 'AV'
                                          ? GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (_selectedBookingHour !=
                                                      null) {
                                                    _selectedBookingHour = DateTime
                                                                .tryParse(
                                                                    _selectedBookingHour!
                                                                        .availability!) ==
                                                            e.dateTime
                                                        ? null
                                                        : NextAvailability(
                                                            availability: e
                                                                .dateTime
                                                                .toString(),
                                                            appointmentType:
                                                                _typeAppoinmentSelected);
                                                  } else {
                                                    _selectedBookingHour =
                                                        NextAvailability(
                                                            availability: e
                                                                .dateTime
                                                                .toString(),
                                                            appointmentType:
                                                                _typeAppoinmentSelected);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: _selectedBookingHour !=
                                                            null
                                                        ? DateTime.tryParse(
                                                                    _selectedBookingHour!
                                                                        .availability!) ==
                                                                e.dateTime
                                                            ? Constants
                                                                .primaryColor400
                                                            : Constants
                                                                .tertiaryColor100
                                                        : Constants
                                                            .tertiaryColor100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9),
                                                    border: Border.all(
                                                        color: _selectedBookingHour !=
                                                                null
                                                            ? DateTime.tryParse(
                                                                        _selectedBookingHour!
                                                                            .availability!) ==
                                                                    e.dateTime
                                                                ? Constants
                                                                    .primaryColor600
                                                                : Constants
                                                                    .extraColor200
                                                            : Constants
                                                                .extraColor200)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      DateFormat('HH:mm')
                                                          .format(e.dateTime),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          boldoHeadingTextStyle
                                                              .copyWith(
                                                        fontSize: 14,
                                                        color: _selectedBookingHour !=
                                                                null
                                                            ? DateTime.tryParse(
                                                                        _selectedBookingHour!
                                                                            .availability!) ==
                                                                    e.dateTime
                                                                ? Colors.white
                                                                : Constants
                                                                    .extraColor400
                                                            : Constants
                                                                .extraColor400,
                                                      )),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                  color: Constants
                                                      .tertiaryColor100,
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                  border: Border.all(
                                                      color: Constants
                                                          .extraColor200)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    DateFormat('HH:mm')
                                                        .format(e.dateTime),
                                                    textAlign: TextAlign.center,
                                                    style: boldoHeadingTextStyle
                                                        .copyWith(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    )),
                                              ),
                                            ),
                                    )
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
    Key? key,
    required this.chunkArrays,
    required this.notAvailibleThisMonth,
    required this.selectedDate,
    required this.changeDateCallback,
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

class _BookDoctorCard extends StatefulWidget {
  const _BookDoctorCard(
      {Key? key,
      required this.doctor,
      required this.nextAvailability,
      required this.handleBookingHour})
      : super(key: key);
  final Function(NextAvailability) handleBookingHour;
  final String nextAvailability;
  final Doctor doctor;

  @override
  State<_BookDoctorCard> createState() => _BookDoctorCardState();
}

class _BookDoctorCardState extends State<_BookDoctorCard> {
  final List<String> popupRoutes = <String>["Remoto (on line)", "En persona"];
  Future<String?>? _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    return await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top - 130, 50, 0),
      items: popupRoutes.map((String popupRoute) {
        return PopupMenuItem<String>(
          child: Container(
              decoration: const BoxDecoration(color: Constants.accordionbg),
              child: Container(
                height: 50,
                child: ListTile(
                  leading: popupRoute == 'En persona'
                      ? const Icon(
                          Icons.person,
                          color: Colors.black,
                        )
                      : SvgPicture.asset('assets/icon/video.svg'),
                  title: Text(popupRoute),
                ),
              )),
          value: popupRoute,
          padding:
              const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
        );
      }).toList(),
      elevation: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    String availabilityText = "";
    bool isToday = false;

    final actualDay = DateTime.now();
    final parsedAvailability =
        DateTime.parse(widget.nextAvailability).toLocal();
    // int daysDifference = parsedAvailability.difference(actualDay).inDays;
      int daysDifference = daysBetween(actualDay,parsedAvailability);

    // if (actualDay.month == parsedAvailability.month) {
    //   daysDifference = parsedAvailability.day - actualDay.day;
    // }
    if (daysDifference == 0) {
      isToday = true;
    }

    if (isToday) {
      availabilityText = "Disponible Hoy!";
    } else if (daysDifference > 0) {
      availabilityText =
          "Disponible ${DateFormat('EEEE, dd MMMM', Localizations.localeOf(context).languageCode).format(parsedAvailability)}";
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
                        Row(
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
                            const Spacer(),
                            if(widget
                                    .doctor.nextAvailability != null)
                            ShowDoctorAvailabilityIcon(
                                filter: widget
                                    .doctor.nextAvailability!.appointmentType!)
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          DateFormat('EEEE, dd MMMM', Localizations.localeOf(context).languageCode)
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
            child: Center(
              child: GestureDetector(
                onTapDown: (TapDownDetails details) async {
                  if (widget.doctor.nextAvailability!.appointmentType! ==
                      'AV') {
                    final chooseOption =
                        await _showPopupMenu(details.globalPosition);
                    if (chooseOption != null) {
                      DateTime parsedAvailability = DateTime.parse(widget.nextAvailability).toLocal();
                      if (chooseOption == 'En persona') {
                        widget.handleBookingHour(
                          NextAvailability(
                              appointmentType: 'A',
                              availability: parsedAvailability.toString()),
                        );
                      } else {
                        widget.handleBookingHour(
                          NextAvailability(
                              appointmentType: 'V',
                              availability: parsedAvailability.toString()),
                        );
                      }
                    }
                  } else {
                    widget.handleBookingHour(NextAvailability(
                        appointmentType:
                            widget.doctor.nextAvailability!.appointmentType,
                        availability: parsedAvailability.toString()));
                  }
                },
                child: Container(
                  child: Text(
                    'Agendar ahora',
                    style: boldoHeadingTextStyle.copyWith(
                        color: Constants.primaryColor500),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppoinmentWithDateAndType {
  final DateTime dateTime;
  final String appoinmentType;

  AppoinmentWithDateAndType(
      {required this.dateTime, required this.appoinmentType});
}
