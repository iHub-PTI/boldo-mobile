import 'package:boldo/utils/helpers.dart';

class DiagnosticReport {
  String?
  id,
  attachmentNumber,
      description,
      effectiveDate,
      source,
      sourceID,
      type,
      patientNotes;

  List<dynamic>? attachmentUrls;

  DiagnosticReport ({
    this.id,
    this.attachmentNumber,
    this.description,
    this.effectiveDate,
    this.source,
    this.sourceID,
    this.type,
    this.patientNotes,
    this.attachmentUrls,
  });

  factory DiagnosticReport.fromJson(Map<String, dynamic> json,) => DiagnosticReport(
    id: json['id'],
    attachmentNumber: json['attachmentNumber'],
    description: json['description'],
    effectiveDate: json['effectiveDate'],
    source: json['source']!= null ? toLowerCase(json['source']!) : null,
    sourceID: json['sourceID'],
    type: json['category'],
    attachmentUrls: json['attachmentUrls']?.map((e) => {'url': e['url'], 'contentType': e['contentType']}).toList(),
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['description'] = description;
    data['effectiveDate'] = effectiveDate;
    data['category'] = type;
    data['patientNotes'] = patientNotes;
    return data;
  }
}
