import 'package:boldo/models/Organization.dart';

/// Exception for [Organization] models
abstract class OrganizationException implements Exception {
  /// Exception for [Organization] models
  OrganizationException({required this.message});

  /// Exception message
  final String message;

  @override
  String toString() => message;
}

/// Exception to represent a unknown Type of organization
class OrganizationTypeNotFound extends OrganizationException {
  /// Exception to represent a unknown Type of organization
  OrganizationTypeNotFound({required String? type})
      : super(message: '$type not found in ${OrganizationType.values}');
}
