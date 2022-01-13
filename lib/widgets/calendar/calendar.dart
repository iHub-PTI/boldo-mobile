import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/CalendarItem.dart';
import '../../constants.dart';

class CustomCalendar extends StatefulWidget {
  final List<List<CalendarItem>> calendarItems;
  final bool notAvailibleThisMonth;
  final DateTime selectedDate;
  final Function(DateTime changeDateCallback) changeDateCallback;

  CustomCalendar({
    Key? key,
    required this.notAvailibleThisMonth,
    required this.calendarItems,
    required this.selectedDate,
    required this.changeDateCallback,
  }) : super(key: key);

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

final List<String> listOfDays = ["D", "L", "M", "M", "J", "V", "S"];

class _CustomCalendarState extends State<CustomCalendar> {
  bool _calendarLoading = false;
  late DateTime selectedMonth;
  @override
  void initState() {
    selectedMonth = widget.selectedDate;
    super.initState();
  }

  void getCalendarItems(
      {required DateTime selectedDate, bool initialLoad = false}) async {
    setState(() {
      _calendarLoading = true;
      selectedMonth = selectedDate;
    });

    await widget.changeDateCallback(selectedDate);

    _calendarLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                iconSize: 28,
                onPressed: () {
                  DateTime now =
                      DateTime(DateTime.now().year, DateTime.now().month);
                  DateTime pastMonth = DateTime(
                    selectedMonth.year,
                    selectedMonth.month - 1,
                  );

                  if (now == pastMonth || now.isBefore(pastMonth)) {
                    getCalendarItems(
                      selectedDate: pastMonth,
                    );
                  }
                },
                icon: const Icon(
                  Icons.chevron_left_rounded,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                DateFormat('MMMM').format(selectedMonth),
                style: boldoHeadingTextStyle.copyWith(
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                  iconSize: 28,
                  onPressed: () {
                    getCalendarItems(
                      selectedDate: DateTime(
                        selectedMonth.year,
                        selectedMonth.month + 1,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                  )),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          constraints: const BoxConstraints(
            maxWidth: 350,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ...listOfDays
                      .map(
                        (e) => Container(
                          height: 40,
                          width: 40,
                          margin: const EdgeInsets.all(4),
                          child: Center(
                            child: Text(
                              e,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                      .toList()
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              if (_calendarLoading == true)
                Container(
                    height: 300,
                    child: const Center(
                        child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor400),
                      backgroundColor: Constants.primaryColor600,
                    ))),
              if (widget.notAvailibleThisMonth)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text("The doctor is not availible this month"),
                ),
              if (_calendarLoading == false && !widget.notAvailibleThisMonth)
                for (int i = 0; i < 6; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...widget.calendarItems[i]
                          .map((calendarItem) => CalendarDay(
                                calendarItem: calendarItem,
                                selectedItem: widget.selectedDate,
                                getItemsForDayCallback:
                                    widget.changeDateCallback,
                              ))
                          .toList(),
                    ],
                  ),
            ],
          ),
        )
      ],
    );
  }
}

class CalendarDay extends StatelessWidget {
  const CalendarDay({
    Key? key,
    required this.calendarItem,
    this.getItemsForDayCallback,
    required this.selectedItem,
  }) : super(key: key);

  final CalendarItem calendarItem;
  final DateTime selectedItem;
  final getItemsForDayCallback;

  @override
  Widget build(BuildContext context) {
    final bool itemEmpty = calendarItem.isEmpty!;
    final bool itemDisabled = calendarItem.isDisabled!;
    final DateTime now = DateTime.now();

    return GestureDetector(
      onTap: () {
        bool pastDay = calendarItem.itemDate!
            .isAfter(DateTime(now.year, now.month, now.day - 1));

        if (itemEmpty || !pastDay || itemDisabled) {
          return;
        }

        getItemsForDayCallback(
          calendarItem.itemDate,
        );
      },
      child: Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.all(4),
        child: Center(
          child: itemEmpty
              ? Container()
              : Text(
                  calendarItem.itemDate!.day.toString(),
                  style: TextStyle(
                    color: itemDisabled
                        ? Constants.extraColor200
                        : calendarItem.itemDate ==
                                DateTime(selectedItem.year, selectedItem.month,
                                    selectedItem.day)
                            ? Colors.white
                            : calendarItem.itemDate!
                                        .difference(DateTime(
                                            now.year, now.month, now.day))
                                        .inDays ==
                                    0
                                ? Constants.otherColor100
                                : !calendarItem.itemDate!.isAfter(DateTime(
                                        now.year, now.month, now.day - 1))
                                    ? Constants.extraColor200
                                    : Constants.extraColor400,
                    fontSize: 17,
                  ),
                ),
        ),
        decoration: BoxDecoration(
            color: !itemEmpty &&
                    calendarItem.itemDate ==
                        DateTime(selectedItem.year, selectedItem.month,
                            selectedItem.day)
                ? Constants.otherColor100
                : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
      ),
    );
  }
}
