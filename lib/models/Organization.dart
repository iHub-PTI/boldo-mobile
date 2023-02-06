class Organization {

  String? id,
  name, type, coloCode;

  bool? active;

  Organization({
    this.active,
    this.id,
    this.name,
    this.type,
    this.coloCode
  });

  Organization.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    id = json['id'];
    name = json['name'];
    type = json['type'];
    coloCode = json['colorCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}