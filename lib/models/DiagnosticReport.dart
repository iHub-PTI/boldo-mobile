import 'package:boldo/models/News.dart';
import 'package:boldo/screens/dashboard/tabs/components/news_cards.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/material.dart';

class DiagnosticReport extends News  {
  String?
  id,
  attachmentNumber,
      description,
      effectiveDate,
      source,
      sourceID,
      type,
      notes,
      sourceType,
      serviceRequestId;

  List<AttachmentUrl>? attachmentUrls;

  DiagnosticReport ({
    this.id,
    this.attachmentNumber,
    this.description,
    this.effectiveDate,
    this.source,
    this.sourceID,
    this.type,
    this.notes,
    this.attachmentUrls,
    this.serviceRequestId,
    this.sourceType,
  });

  factory DiagnosticReport.fromJson(Map<String, dynamic> json,) => DiagnosticReport(
    id: json['id'],
    attachmentNumber: json['attachmentNumber'],
    description: json['description'],
    effectiveDate: json['effectiveDate'],
    source: json['source']!= null ? toLowerCase(json['source']!) : null,
    sourceID: json['sourceID'],
    type: json['category'],
    notes: json['notes'],
    serviceRequestId: json['serviceRequestId'],
    attachmentUrls: json['attachmentUrls']!= null ? List<AttachmentUrl>.from(json['attachmentUrls'].map((e) => AttachmentUrl.fromJson(e) )) : null,
    sourceType: json['sourceType'],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['description'] = description;
    data['effectiveDate'] = effectiveDate;
    data['category'] = type;
    data['notes'] = notes;
    data['serviceRequestId'] = serviceRequestId;
    data['attachmentUrls'] = attachmentUrls?.map((e) => e.toJson()).toList();
    return data;
  }

  @override
  Widget show() {
    return DiagnosticReportCard(diagnosticReport: this);
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