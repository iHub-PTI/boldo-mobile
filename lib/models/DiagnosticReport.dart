import 'package:boldo/utils/helpers.dart';

class DiagnosticReport {
  String?
  attachmentNumber,
      description,
      effectiveDate,
      source,
      sourceID,
      type,
      patientNotes;

  DiagnosticReport ({
    this.attachmentNumber,
    this.description,
    this.effectiveDate,
    this.source,
    this.sourceID,
    this.type,
    this.patientNotes,
  });

  factory DiagnosticReport.fromJson(Map<String, dynamic> json,) => DiagnosticReport(
    attachmentNumber: json['attachmentNumber'],
    description: json['description']!= null ? toLowerCase(json['description']!) : null,
    effectiveDate: json['effectiveDate'],
    source: json['source']!= null ? toLowerCase(json['source']!) : null,
    sourceID: json['sourceID'],
    type: json['category'],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['attachmentNumber'] = attachmentNumber;
    data['description'] = description;
    data['effectiveDate'] = effectiveDate;
    data['source'] = source;
    data['sourceID'] = sourceID;
    data['category'] = type;
    data['patientNotes'] = patientNotes;
    return data;
  }
}
