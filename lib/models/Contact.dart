class Contact {

  String? type, value;

  Contact({
    this.type,
    this.value,
  });

  Contact.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['type'] = type;
    data['value'] = value;
    return data;
  }
}