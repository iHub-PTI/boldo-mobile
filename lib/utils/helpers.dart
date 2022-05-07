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
    _result += "${a[0].toUpperCase()}${a.substring(1).toLowerCase()} ";
  }
  return "$_result";
}