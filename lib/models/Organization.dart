import 'package:boldo/constants.dart';
import 'package:boldo/models/AddressEntity.dart';
import 'package:boldo/models/Contact.dart';
import 'package:boldo/models/PositionEntity.dart';
import 'package:boldo/screens/organizations/memberships_screen.dart';
import 'package:boldo/screens/pharmacy/pharmacy_availables.dart';
import 'package:boldo/utils/errors.dart';
import 'package:flutter/material.dart';

class Organization {

  OrganizationType? organizationType;

  String? id;
  String? name;
  String? type;
  String? coloCode;
  String? logoUrl;
  String? typeDisplay;
  String? visibilityDisplay;
  String? visibility;

  /// Organization father id
  String? organizationId;

  /// Organization father id
  String? organzationName;

  bool? active;

  OrganizationSettings? organizationSettings;

  List<Contact>? contactList;

  AddressEntity? address;

  PositionEntity? position;

  /// integer that define the user preference to get doctors by organization
  int? priority;

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
    this.organzationName,
    this.position,
  }){
try {
      organizationType =
          OrganizationType.values.firstWhere((element) => element.codeType ==
              type);
    }on StateError catch(exception, stacktrace) {
      captureError(
        exception: exception,
        stackTrace: stacktrace,
        data: {
          'type': type,
        }
      );
    }
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    bool? _active = json['active'];
    String? _id = json['id'];
    String? _name = json['name'];
    _name = _name?.trimRight().trimLeft();
    String? _type = json['type'];
    String? _coloCode = json['colorCode'];
    int? _priority = json['priority'];

    List<Contact>? _contactList;
    if (json['contactDtoList'] != null) {
      _contactList = [];
      json['contactDtoList'].forEach((v) {
        _contactList!.add(Contact.fromJson(v));
      });
    }
    String? _logoUrl = json['logoUrl'];
    String? _typeDisplay = json['typeDisplay'];
    AddressEntity? _address;
    if (json['addressDto'] != null) {
      _address = AddressEntity.fromJson(json['addressDto']);
    }
    String? _visibilityDisplay = json['visibilityDisplay'];
    String? _visibility = json['visibility'];
    OrganizationSettings? _organizationSettings;
    if( json['organizationSettings'] != null ){
      _organizationSettings = OrganizationSettings.fromJson(json['organizationSettings']);
    }

    String? _organizationId = json['organizationId'];

    String? _organizationName = json['organizationName'];

    PositionEntity? _position;

    if( json['position'] != null ){
      _position = PositionEntity.fromJson(json['position']);
    }

    return Organization(
      id: _id,
      active: _active,
      name: _name,
      type: _type,
      coloCode: _coloCode,
      priority: _priority,
      contactList: _contactList,
      logoUrl: _logoUrl,
      typeDisplay: _typeDisplay,
      address: _address,
      visibilityDisplay: _visibilityDisplay,
      visibility: _visibility,
      organizationSettings: _organizationSettings,
      organizationId: _organizationId,
      organzationName: _organizationName,
      position: _position,
    );

  }

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

    switch (statusCode){
      case 'PD':
        status = StatusRequestOrganization.Pending;
        break;
      case 'AP':
        status = StatusRequestOrganization.Approved;
        break;
      case 'RJ':
        status = StatusRequestOrganization.Rejected;
        break;
      default:
        status = null;
    }

  }
}

enum OrganizationType {
  pharmacy(
    svgPath: 'assets/icon/local-pharmacy.svg',
    infoCardTitle: 'Farmacias adheridas',
    page: PharmaciesScreen(),
    codeType: 'PHARMACY'
  ),
  hospital(
    svgPath: 'assets/icon/local-hospital.svg',
    infoCardTitle: 'Centros asistenciales',
    page: OrganizationsSubscribedScreen(),
    codeType: 'HEALTHCARE-PROVIDER'
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

class OrganizationSettings {

  bool? setLogoInReports,
  automaticPatientSubscription;
  
  List<OrganizationRequirement>? organizationRequirements;

  OrganizationSettings({
    this.setLogoInReports,
    this.automaticPatientSubscription,
    this.organizationRequirements,
  });

  factory OrganizationSettings.fromJson(Map<String, dynamic> json,) => OrganizationSettings(
    setLogoInReports: json["setLogoInReports"],
    automaticPatientSubscription: json["automaticPatientSubscription"],
    organizationRequirements: json["organizationRequirements"] != null
        ? List<OrganizationRequirement>.from(
        json["organizationRequirements"].map((element) => OrganizationRequirement.fromJson(element))
    ) : json["automaticPatientSubscription"] ? List<OrganizationRequirement>.from([
      OrganizationRequirement(
        title: "¿Cuenta con seguro médico?",
        description: "Para acceder a los servicios del centro es requisito NO contar con seguro médico",
        answer: false,
      ),
    ]) : null,
  );

}

class OrganizationRequirement {

  String? title,
  description,
  observation;

  bool? answer;

  OrganizationRequirement({
    this.title,
    this.description,
    this.observation,
    this.answer,
  });

  factory OrganizationRequirement.fromJson(Map<String, dynamic> json,) => OrganizationRequirement(
    title: json["title"],
    description: json["description"],
    observation: json["observation"],
    answer: json["answer"],
  );

}