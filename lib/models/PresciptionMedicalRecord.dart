

class PrescriptionMedicalRecord {
  String medicationId;
  String medicationName;

  
  PrescriptionMedicalRecord({
    this.medicationId,
    this.medicationName,
  });


  PrescriptionMedicalRecord.fromJson(Map<String, dynamic> json) {
    medicationId = json['medicationId'];
    medicationName = json['medicationName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['medicationId'] = medicationId;
    data['medicationName'] = medicationName;
    return data;
  }
}
