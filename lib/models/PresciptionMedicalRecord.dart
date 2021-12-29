

class PrescriptionMedicalRecord {
  String medicationId;
  String medicationName;
  String instructions;
  
  PrescriptionMedicalRecord({
    this.medicationId,
    this.medicationName,
  });


  PrescriptionMedicalRecord.fromJson(Map<String, dynamic> json) {
    medicationId = json['medicationId'];
    medicationName = json['medicationName'];
     instructions = json["instructions"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['medicationId'] = medicationId;
    data['medicationName'] = medicationName;
     data["instructions"] = instructions;
    return data;
  }
}
