import 'package:boldo/constants.dart';
import 'package:boldo/core/core.dart';
import 'package:boldo/models/AddressEntity.dart';
import 'package:boldo/models/Contact.dart';
import 'package:boldo/models/PositionEntity.dart';
import 'package:boldo/screens/organizations/memberships_screen.dart';
import 'package:boldo/screens/pharmacy/pharmacy_availables.dart';
import 'package:boldo/utils/errors.dart';
import 'package:flutter/material.dart';

/// Represent an organization or a subsidiary
class Organization {
  /// Represent an organization or a subsidiary
  Organization({
    this.active,
    this.id,
    this.name,
    this.type,
    this.coloCode,
    this.priority,
    this.organizationSettings,
    this.contactList,
    this.address,
    this.logoUrl,
    this.typeDisplay,
    this.visibility,
    this.visibilityDisplay,
    this.organizationId,
    this.organizationName,
    this.position,
    this.services,
  }) {
    try {
      organizationType = OrganizationType.values.firstWhere(
        (element) => element.codeType == type,
        orElse: () => throw OrganizationTypeNotFound(
          type: type,
        ),
      );
    } on OrganizationTypeNotFound catch (exception, stacktrace) {
      captureMessage(
        message: exception.message,
        stackTrace: stacktrace,
        data: {
          'type': type,
        },
      );
    }
  }

  /// Represent an organization or a subsidiary
  factory Organization.fromJson(Map<String, dynamic> json) {
    final active = json['active'] as bool?;
    final id = json['id'] as String?;
    var name = json['name'] as String?;
    name = name?.trimRight().trimLeft();
    final type = json['type'] as String?;
    final coloCode = json['colorCode'] as String?;
    final priority = json['priority'] as int?;

    List<Contact>? contactList;
    if (json['contactDtoList'] != null) {
      contactList = [];
      for (final v in json['contactDtoList'] as List<dynamic>) {
        contactList.add(Contact.fromJson(v));
      }
    }
    final logoUrl = json['logoUrl'] as String?;
    final typeDisplay = json['typeDisplay'] as String?;
    AddressEntity? address;
    if (json['addressDto'] != null) {
      address = AddressEntity.fromJson(json['addressDto']);
    }
    final visibilityDisplay = json['visibilityDisplay'] as String?;
    final visibility = json['visibility'] as String?;
    OrganizationSettings? organizationSettings;
    if (json['organizationSettings'] != null) {
      organizationSettings =
          OrganizationSettings.fromJson(json['organizationSettings']);
    }

    final organizationId = json['organizationId'] as String?;

    final organizationName = json['organizationName'] as String?;

    PositionEntity? position;

    if (json['position'] != null) {
      position = PositionEntity.fromJson(json['position']);
    }

    List<Service>? services;
    if (json['services'] != null) {
      services = [];
      for (final service in json['services'] as List<dynamic>) {
        services.add(Service.fromJson(service));
      }
    }

    return Organization(
      id: id,
      active: active,
      name: name,
      type: type,
      coloCode: coloCode,
      priority: priority,
      contactList: contactList,
      logoUrl: logoUrl,
      typeDisplay: typeDisplay,
      address: address,
      visibilityDisplay: visibilityDisplay,
      visibility: visibility,
      organizationSettings: organizationSettings,
      organizationId: organizationId,
      organizationName: organizationName,
      position: position,
      services: services,
    );
  }

  /// internal organization type based on [type] string
  OrganizationType? organizationType;

  /// FHIR identifier
  String? id;

  /// Name label of the organization
  String? name;

  /// String type of organization
  String? type;

  /// color code, unused
  String? coloCode;

  /// picture of the organization
  String? logoUrl;

  /// Label of organization type
  String? typeDisplay;

  ///
  String? visibilityDisplay;
  String? visibility;

  /// Organization father id
  String? organizationId;

  /// Organization father id
  String? organizationName;

  bool? active;

  OrganizationSettings? organizationSettings;

  List<Contact>? contactList;

  AddressEntity? address;

  PositionEntity? position;

  /// list of services available to offer the subsidiary
  List<Service>? services;

  /// integer that define the user preference to get doctors by organization
  int? priority;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class OrganizationRequest {
  String? id,
      organizationId,
      organizationName,
      patientId,
      patientRequestingId,
      statusCode,
      statusDisplay;

  StatusRequestOrganization? status;

  OrganizationRequest({
    this.id,
    this.organizationId,
    this.organizationName,
    this.patientId,
    this.patientRequestingId,
    this.statusCode,
    this.statusDisplay,
  });

  OrganizationRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    organizationId = json['organizationId'];
    organizationName = json['organizationName'];
    patientId = json['patientId'];
    patientRequestingId = json['patientRequestingId'];
    statusCode = json['statusCode'];
    statusDisplay = json['statusDisplay'];

    switch (statusCode) {
      case 'PD':
        status = StatusRequestOrganization.Pending;
      case 'AP':
        status = StatusRequestOrganization.Approved;
      case 'RJ':
        status = StatusRequestOrganization.Rejected;
      default:
        status = null;
    }
  }
}

/// Types or {Organization} available in App
enum OrganizationType {
  /// A pharmacy
  pharmacy(
    svgPath: 'assets/icon/local-pharmacy.svg',
    infoCardTitle: 'Farmacias adheridas',
    page: PharmaciesScreen(),
    codeType: 'PHARMACY',
  ),

  /// An HEALTHCARE-PROVIDER
  hospital(
    svgPath: 'assets/icon/local-hospital.svg',
    infoCardTitle: 'Centros asistenciales',
    page: OrganizationsSubscribedScreen(),
    codeType: 'HEALTHCARE-PROVIDER',
  );

  const OrganizationType({
    required this.svgPath,
    required this.infoCardTitle,
    this.iconColor = ConstantsV2.activeText,
    this.page,
    required this.codeType,
  });
  final String svgPath;
  final String infoCardTitle;
  final Color iconColor;
  final Widget? page;
  final String codeType;
}

/// A setting that describe if the organization is free to subscribed
class OrganizationSettings {
  /// A setting that describe if the organization is free to subscribed
  OrganizationSettings({
    this.setLogoInReports,
    this.automaticPatientSubscription,
    this.organizationRequirements,
  });

  /// A setting that describe if the organization is free to subscribed
  factory OrganizationSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    List<OrganizationRequirement>? organizationsRequirement;
    if (json['organizationRequirements'] != null) {
      organizationsRequirement = [];
      for (final v in json['organizationRequirements'] as List<dynamic>) {
        organizationsRequirement.add(OrganizationRequirement.fromJson(v));
      }
    }
    return OrganizationSettings(
      setLogoInReports: json['setLogoInReports'],
      automaticPatientSubscription: json['automaticPatientSubscription'],
      organizationRequirements: json['organizationRequirements'] != null
          ? organizationsRequirement
          : json['automaticPatientSubscription']
              ? List<OrganizationRequirement>.from([
                  OrganizationRequirement(
                    title: '¿Cuenta con seguro médico?',
                    description:
                        'Para acceder a los servicios del centro es requisito NO contar con seguro médico',
                    answer: false,
                  ),
                ])
              : null,
    );
  }

  /// if has logo in reports like Study order
  bool? setLogoInReports;

  /// if the patient can autoSubscribe, his request was automatic approved
  bool? automaticPatientSubscription;

  /// List of questions to postulate
  List<OrganizationRequirement>? organizationRequirements;
}

class OrganizationRequirement {
  String? title;
  String? description;
  String? observation;

  bool? answer;

  OrganizationRequirement({
    this.title,
    this.description,
    this.observation,
    this.answer,
  });

  factory OrganizationRequirement.fromJson(
    Map<String, dynamic> json,
  ) =>
      OrganizationRequirement(
        title: json["title"],
        description: json["description"],
        observation: json["observation"],
        answer: json["answer"],
      );
}
