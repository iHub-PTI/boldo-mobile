String getDoctorPrefix(String gender) {
  return gender == "male" ? "Dr." : "Dra.";
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
