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

  List<AttachmentUrl>? attachmentUrls;

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
    attachmentUrls: json['attachmentUrls']!= null ? List<AttachmentUrl>.from(json['attachmentUrls'].map((e) => AttachmentUrl.fromJson(e) )) : null,
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

class AttachmentUrl {
  String? url,
      contentType,
      title;

  AttachmentUrl({
    this.url,
    this.contentType,
    this.title,
  });

  factory AttachmentUrl.fromJson(Map<String, dynamic> json,) =>
      AttachmentUrl(
        url: json['url'],
        contentType: json['contentType'],
        title: json['title'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['url'] = url;
    data['contentType'] = contentType;
    return data;
  }

}