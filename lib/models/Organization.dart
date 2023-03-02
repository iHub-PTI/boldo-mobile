class Organization {

  String? id,
  name, type, coloCode;

  bool? active;

  /// integer that define the user preference to get doctors by organization
  int? priority;

  Organization({
    this.active,
    this.id,
    this.name,
    this.type,
    this.coloCode,
    this.priority,
  });

  Organization.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    id = json['id'];
    name = json['name'];
    type = json['type'];
    coloCode = json['colorCode'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}