import 'package:flutter/material.dart';

class Soep {
  String? evaluation;
  String? objective;
  String? plan;
  String? subjective;

  Soep({this.evaluation, this.objective, this.plan, this.subjective});

  Soep.fromJson(Map<String, dynamic> json) {
    evaluation = json['evaluation'];
    objective = json['objective'];
    plan = json['plan'];
    subjective = json['subjective'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['evaluation'] = evaluation;
    data['objective'] = objective;
    data['plan'] = plan;
    data['subjective'] = subjective;

    return data;
  }
}
