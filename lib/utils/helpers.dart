import 'package:sentry_flutter/sentry_flutter.dart';

String getDoctorPrefix(String gender) {
  if (gender == "female") return "Dra. ";
  if (gender == "male") return 'Dr. ';
  return "";
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String toLowerCase(String word){
  var words = word.split(" ");
  String _result = "";
  for(String a in words){
    if(a!= "")
    _result += "${a[0].toUpperCase()}${a.substring(1).toLowerCase()} ";
  }
  return "$_result";
}

String? spanishGenderToEnglish(String? word){
  if(word == null){
    return null;
  }
  if(word.toLowerCase() == 'masculino')
    return 'male';
  if(word.toLowerCase() == 'femenino')
    return 'female';
  return 'unknow';
}

String? getTypeFromContentType(String? content) {
  try{
    if(content == null){
      return null;
    }
    var words = content.split("/");
    return words[1];
  }catch (e){
    Sentry.captureException(e);
    return null;
  }
}

// set local date with format aaaa-mm-dd 00:00.000 for prevent days difference
// get a bug, e.g: 30/06 21:00hs difference with 01/07 18:00, days difference
// is calculated whit hours differences resulting <24:hs -> days = 0, therefore
// this is presented like the same day
 int daysBetween(DateTime from, DateTime to) {
     from = DateTime(from.year, from.month, from.day);
     to = DateTime(to.year, to.month, to.day);
     print(to.difference(from).inHours);
   return (to.difference(from).inHours / 24).round();
  }