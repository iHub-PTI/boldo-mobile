import 'package:boldo/models/Doctor.dart';
import 'package:intl/intl.dart';

import 'Filter.dart';
import 'package:collection/collection.dart';


class PrescriptionFilter  extends Filter {

  DateTime? _start;

  DateTime? get start => _start;

  set start (DateTime? newStartDate){
    _start = newStartDate;
  }

  DateTime? _end;

  DateTime? get end => _end;

  set end (DateTime? newStartDate){
    _end = newStartDate;
  }

  /// List of doctors ids
  List<Doctor?>? _doctors;

  List<Doctor?>? get doctors => _doctors;

  set doctors (List<Doctor?>? newDoctors){
    _doctors = newDoctors;
  }

  PrescriptionFilter({
    DateTime? start,
    DateTime? end,
    List<Doctor?>? doctors,
  }){
    _start = start;
    _end = end;
    _doctors = doctors;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> _json;

    _json = {
      'doctors': doctors?.map((e) => e?.id).toList(),
      'start': start?.toUtc().toIso8601String(),
      'end': end?.toUtc().toIso8601String(),
    };

    _json.removeWhere((key, value) => value == null);

    return _json;

  }

  @override
  Future<void> clearFilter() async {
    start = null;
    end = null;
    doctors = null;
  }

  @override
  bool get ifFiltered {
    return start != null || end != null || doctors?.isNotEmpty != null;
  }

  @override
  bool operator ==(Object other) {
    DeepCollectionEquality eq = const DeepCollectionEquality.unordered();
    if(other is PrescriptionFilter) {
      return start == other.start && end == other.end && eq.equals(doctors,other.doctors);
    }
    else{
      return false;
    }
  }

  @override
  int get hashCode => Object.hashAll([start, end, doctors]);

  PrescriptionFilter copyWith({
    DateTime? start,
    DateTime? end,
    List<Doctor?>? doctors,
  }) => PrescriptionFilter(
    start: start?? this.start,
    end: end?? this.end,
    doctors: doctors?? this.doctors,
  );

}