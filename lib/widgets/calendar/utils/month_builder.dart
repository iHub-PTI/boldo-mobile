
import 'package:boldo/screens/booking/booking_screen.dart';

import '../../../models/CalendarItem.dart';

List<List<CalendarItem>> monthBuilder(
    {required DateTime buildDate,
    required List<AppoinmentWithDateAndType> allAvailabilities}) {
  List<List<CalendarItem>> chunkArrays = [[], [], [], [], [], []];
  int fillingArray = 0;
  int day = 1;

  while (day <= DateTime(buildDate.year, buildDate.month + 1, 0).day) {
    DateTime date = DateTime(buildDate.year, buildDate.month, day);
    chunkArrays[fillingArray].add(
      CalendarItem(
        itemDate: date,
        isEmpty: false,
        isDisabled: !allAvailabilities.any((element) =>
            DateTime(element.dateTime.year, element.dateTime.month, element.dateTime.day)
                .difference(date)
                .inDays ==
            0),
      ),
    );

    if (DateTime(buildDate.year, buildDate.month, day).weekday == 6) {
      fillingArray++;
    }
    day++;
  }
  //fill in the white space of the calendart
  //filling up the possible whitespace on row 1
  final chunk1ArrayLength = chunkArrays[0].length;
  if (chunk1ArrayLength < 7) {
    for (var i = 0; i < 7 - chunk1ArrayLength; i++) {
      chunkArrays[0].insert(0, CalendarItem(isEmpty: true, isDisabled: true));
    }
  }
  //filling up the possible whitespace on row 4
  final chunk4ArrayLength = chunkArrays[4].length;
  if (chunk4ArrayLength < 7) {
    for (var i = 0; i < 7 - chunk4ArrayLength; i++) {
      chunkArrays[4].add(CalendarItem(isEmpty: true, isDisabled: true));
    }
  }
  //filling up the possible whitespace on row 5
  final chunk5ArrayLength = chunkArrays[5].length;
  if (chunk5ArrayLength != 0 && chunk5ArrayLength < 7) {
    for (var i = 0; i < 7 - chunk5ArrayLength; i++) {
      chunkArrays[5].add(CalendarItem(isEmpty: true, isDisabled: true));
    }
  }

  return chunkArrays;
}
