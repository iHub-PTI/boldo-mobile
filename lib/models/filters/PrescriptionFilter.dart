class PrescriptionFilter {

  DateTime? start;
  DateTime? end;

  /// List of doctors ids
  List<String>? doctors;

  PrescriptionFilter({
    this.start,
    this.end,
    this.doctors,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> _json;

    _json = {
      'doctors': doctors,
      'start': start?.toIso8601String(),
      'end': end?.toIso8601String(),
    };

    _json.removeWhere((key, value) => value == null);

    return _json;

  }

}