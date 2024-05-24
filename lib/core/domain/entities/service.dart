import 'package:boldo/models/Specialization.dart';

/// Represent a speciality for an appointment
class Service {
  /// Represent a speciality for an appointment
  Service({
    this.id,
    this.name,
    this.specialiations,
  });

  /// Represent a speciality for an appointment
  factory Service.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    final specializations = json['specializations'] != null
        ? List<Specialization>.from(
            (json['specializations'] as List<Map<String, dynamic>>)
                .map(Specialization.fromJson),
          )
        : null;
    return Service(
      id: id,
      name: name,
      specialiations: specializations,
    );
  }

  /// the identifier
  final String? id;

  /// the label of the Service
  final String? name;

  /// List of specializations asociated with the Service
  final List<Specialization>? specialiations;
}
