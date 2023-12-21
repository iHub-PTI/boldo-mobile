
/// example
/// [description] '10Mb'
/// [maxSizeBytes] 10485760
class FileLimit {
  String description;
  int maxSizeBytes;

  /// example
  ///
  /// [description] '10Mb'
  ///
  /// [maxSizeBytes] 10485760 (10\*1024\*1024)
  FileLimit({
    required this.description,
    required this.maxSizeBytes,
  });

  factory FileLimit.fromJson(Map<String, dynamic> json) => FileLimit(
    description: json['description'],
    maxSizeBytes: json['maxSizeBytes'],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['description'] = description;
    data['maxSizeBytes'] = maxSizeBytes;
    return data;
  }

}