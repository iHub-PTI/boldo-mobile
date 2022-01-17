import './Encounter.dart';

class Prescription {
  String? instructions;
  String? medicationId;
  String? medicationName;

  Encounter? encounter;

  Prescription({
    this.medicationId,
    this.medicationName,
    this.encounter,
    this.instructions,
  });

  Prescription.fromJson(Map<String, dynamic> json) {
    medicationId = json['medicationId'];
    medicationName = json['medicationName'];

    instructions = json["instructions"];
    encounter = json['encounter'] != null
        ? Encounter.fromJson(json['encounter'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['medicationId'] = medicationId;
    data['medicationName'] = medicationName;
    data["instructions"] = instructions;
    if (encounter != null) {
      data['encounter'] = encounter!.toJson();
    }
    return data;
  }
}
