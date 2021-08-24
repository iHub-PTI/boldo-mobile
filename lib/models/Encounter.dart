class Encounter {
  String appointmentId;
  String diagnosis;
  String instructions;

  Encounter({
    this.appointmentId,
    this.diagnosis,
    this.instructions,
  });

  Encounter.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    diagnosis = json['diagnosis'];
    instructions = json['instructions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['appointmentId'] = appointmentId;
    data['diagnosis'] = diagnosis;
    data['instructions'] = instructions;

    return data;
  }
}
