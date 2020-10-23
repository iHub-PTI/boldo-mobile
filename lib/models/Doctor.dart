class Doctor {
  int id;
  String familyName;
  String givenName;

  Doctor({
    this.id,
    this.familyName,
    this.givenName,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["id"],
      familyName: json["familyName"],
      givenName: json["givenName"],
    );
  }

  Map<String, dynamic> tojson() {
    return <String, dynamic>{
      "id": id,
      "familyName": familyName,
      "givenName": givenName,
    };
  }
}
