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