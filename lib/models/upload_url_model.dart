
import 'dart:convert';

UploadUrl uploadUrlFromJson(dynamic str) => UploadUrl.fromJson(str);

String uploadUrlToJson(UploadUrl data) => json.encode(data.toJson());

class UploadUrl {
  UploadUrl({
    this.uploadUrl,
    this.location,
    this.hash,
  });

  String? uploadUrl;
  String? location;
  String? hash;

  factory UploadUrl.fromJson(Map<String, dynamic> json) => UploadUrl(
    uploadUrl: json["uploadUrl"],
    location: json["location"],
    hash: json["hash"],
  );

  Map<String, dynamic> toJson() => {
    "uploadUrl": uploadUrl,
    "location": location,
    "hash": hash,
  };
}