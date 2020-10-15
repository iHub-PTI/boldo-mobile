import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/CalendarItem.dart';
import './utils/monthBuilder.dart';
import '../../constant.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime selectedDate;

  CustomCalendar({
    Key key,
    @required this.selectedDate,
  }) : super(key: key);

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

final List<String> listOfDays = ["D", "L", "M", "M", "J", "V", "S"];

class _CustomCalendarState extends State<CustomCalendar> {
  List<List<CalendarItem>> calendarItems;
  bool _calendarLoading = true;
  DateTime selectedItem;
  DateTime selectedMonth;

  @override
  void initState() {
    getCalendarItems(selectedDate: widget.selectedDate);
    super.initState();
  }

  getItemsForDay({@required DateTime itemDate}) {
    //set the calendaritem as selected
    setState(() {
      selectedItem = itemDate;
    });
    //fetch the data related to the calendarItem.
  }

  getCalendarItems({DateTime selectedDate}) async {
    setState(() {
      _calendarLoading = true;
      selectedMonth = selectedDate;
    });

    var newState = await monthBuilder(buildDate: selectedDate);

    setState(() {
      _calendarLoading = false;
      calendarItems = newState["chunkArrays"];
    });
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
                  getCalendarItems(
                      selectedDate: DateTime(
                          selectedMonth.year, selectedMonth.month - 1));
                },
                icon: Icon(
                  Icons.chevron_left_rounded,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                DateFormat('MMMM').format(selectedMonth),
                style: boldoHeadingTextStyle.copyWith(
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                width: 20,
              ),
              IconButton(
                  iconSize: 28,
                  onPressed: () {
                    getCalendarItems(
                        selectedDate: DateTime(
                            selectedMonth.year, selectedMonth.month + 1));
                  },
                  icon: Icon(
                    Icons.chevron_right_rounded,
                  )),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          constraints: BoxConstraints(
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
                          margin: EdgeInsets.all(4),
                          child: Center(
                            child: Text(
                              e,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                      .toList()
                ],
              ),
              SizedBox(
                height: 8,
              ),
              if (_calendarLoading == true)
                Container(
                    height: 300,
                    child: Center(child: CircularProgressIndicator())),
              if (_calendarLoading == false)
                for (int i = 0; i < 6; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...calendarItems[i]
                          .map((calendarItem) => CalendarDay(
                                calendarItem: calendarItem,
                                selectedItem: selectedItem,
                                getItemsForDayCallback: getItemsForDay,
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
    Key key,
    this.calendarItem,
    this.getItemsForDayCallback,
    this.selectedItem,
  }) : super(key: key);

  final CalendarItem calendarItem;
  final DateTime selectedItem;
  final getItemsForDayCallback;

  @override
  Widget build(BuildContext context) {
    final bool itemEmpty = calendarItem.isEmpty;
    final DateTime now = DateTime.now();

    return GestureDetector(
      onTap: () {
        bool pastDay = calendarItem.itemDate
            .isAfter(DateTime(now.year, now.month, now.day - 1));

        if (itemEmpty || !pastDay) {
          return;
        }

        getItemsForDayCallback(
          itemDate: calendarItem.itemDate,
        );
      },
      child: Container(
        height: 40,
        width: 40,
        margin: EdgeInsets.all(4),
        child: Center(
          child: itemEmpty
              ? Container()
              : Text(
                  calendarItem.itemDate.day.toString(),
                  style: TextStyle(
                    color: calendarItem.itemDate == selectedItem
                        ? Colors.white
                        : calendarItem.itemDate
                                    .difference(
                                        DateTime(now.year, now.month, now.day))
                                    .inDays ==
                                0
                            ? boldoCategoryColor
                            : !calendarItem.itemDate.isAfter(
                                    DateTime(now.year, now.month, now.day - 1))
                                ? boldoTextLightGrayColor
                                : boldoTitleTextColor,
                    fontSize: 17,
                  ),
                ),
        ),
        decoration: BoxDecoration(
            color: !itemEmpty && calendarItem.itemDate == selectedItem
                ? boldoCategoryColor
                : Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    );
  }
}
