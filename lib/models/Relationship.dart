class Relationship {
  String? code,
      display,
      displaySpan;

  Relationship({this.code,
    this.display,
    this.displaySpan,});

  factory Relationship.fromJson(Map<String, dynamic> json,) =>
      Relationship(
          code: json['code'],
          display: json['display'],
          displaySpan: json['displaySpan'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['code'] = code;
    data['display'] = display;
    data['displaySpan'] = displaySpan;
    return data;
  }
}