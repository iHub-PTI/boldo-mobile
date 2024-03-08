class Encounter {
  String? encounterId;
  String? appointmentId;
  String? diagnosis;
  String? instructions;

  Encounter({
    this.appointmentId,
    this.diagnosis,
    this.instructions,
    this.encounterId,
  });

  Encounter.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    diagnosis = json['diagnosis'];
    instructions = json['instructions'];
    encounterId = json['encounterId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['appointmentId'] = appointmentId;
    data['diagnosis'] = diagnosis;
    data['instructions'] = instructions;

    return data;
  }
}
