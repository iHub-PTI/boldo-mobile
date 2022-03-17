class Specialization {
  String? id;
  String? description;

  Specialization({
     this.id,
     this.description,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json["id"],
      description: json["description"],
    );
  }

  Map<String, dynamic> tojson() {
    return <String, dynamic>{
      "id": id,
      "description": description,
    };
  }
}
