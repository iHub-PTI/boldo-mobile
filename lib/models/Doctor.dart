class Doctor {
  int id;
  String name;

  Doctor({
    this.id,
    this.name,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> tojson() {
    return <String, dynamic>{
      "id": id,
      "name": name,
    };
  }
}
