import 'package:flutter/material.dart';

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

  Widget typeIcon ({Color? color}) {
    IconData defaultIcon = Icons.question_mark_rounded;

    Map<String, IconData> iconsType ={
      "phone": Icons.phone_outlined,
      "email": Icons.email_outlined,
    };

    return Icon(
      iconsType[type]?? defaultIcon,
      size: 16,
      color: color,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['type'] = type;
    data['value'] = value;
    return data;
  }
}