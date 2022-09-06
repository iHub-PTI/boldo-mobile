
class StudyOrder {
  String? id;
  String? category;
  String? diagnosis;
  String? encounterId;
  String? notes;
  List<StudiesCodes>? studiesCodes;

  bool? urgent;

  StudyOrder({
    this.id,
    this.category,
    this.diagnosis,
    this.encounterId,
    this.studiesCodes,
    this.notes,
    this.urgent,
  });

  StudyOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    diagnosis = json['diagnosis'];
    urgent = json['urgent'];
    encounterId = json['encounterId'];
    notes = json['notes'];
    studiesCodes = json['studiesCodes'] != null
        ? List<StudiesCodes>.from(json["studiesCodes"]
        .map((x) => StudiesCodes.fromJson(x)))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['category'] = category;
    data['diagnosis'] = diagnosis;

    return data;
  }
}

class StudiesCodes {
  String? code,
      display,
      note;

  StudiesCodes({
    this.code,
    this.display,
    this.note,
  });

  factory StudiesCodes.fromJson(Map<String, dynamic> json,) =>
      StudiesCodes(
        code: json['code'],
        display: json['display'],
        note: json['notes'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['notes'] = note;
    data['display'] = display;
    return data;
  }

}