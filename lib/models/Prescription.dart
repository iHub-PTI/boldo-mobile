import 'package:boldo/models/Encounter.dart';

/// Represent a prescription with instructions
class Prescription {
  /// Represent a prescription with instructions
  Prescription({
    this.medicationId,
    this.medicationName,
    this.encounter,
    this.instructions,
    this.encounterId,
  });

  /// Represent a prescription with instructions
  factory Prescription.fromJson(Map<String, dynamic> json) {
    final medicationId = json['medicationId'] as String?;
    final medicationName = json['medicationName'] as String?;

    final instructions = json['instructions'] as String?;
    final encounter = json['encounter'] != null
        ? Encounter.fromJson(json['encounter'])
        : null;
    final encounterId = json['encounterId'] as String?;
    return Prescription(
      medicationId: medicationId,
      encounterId: encounterId,
      medicationName: medicationName,
      instructions: instructions,
      encounter: encounter,
    );
  }

  /// indications to consume the medication
  String? instructions;

  /// medication identifier
  String? medicationId;

  /// commercial name
  String? medicationName;

  /// encounter identifier where the medication was expended
  String? encounterId;

  /// encounter where the medication was expended
  Encounter? encounter;
}
