import 'package:boldo/constants.dart';
import 'package:boldo/models/Contact.dart';
import 'package:boldo/screens/organizations/memberships_screen.dart';
import 'package:boldo/screens/pharmacy/pharmacy_availables.dart';
import 'package:flutter/material.dart';

class Organization {

  OrganizationType? organizationType;

  String? id,
      name,
      type,
      coloCode,
      logoUrl,
      typeDisplay,
      visibilityDisplay,
      visibility
  ;

  bool? active;

  OrganizationSettings? organizationSettings;

  List<Contact>? contactList;

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
  });

  Organization.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    id = json['id'];
    name = json['name'];
    name = name?.trimRight().trimLeft();
    type = json['type'];
    try {
      organizationType =
          OrganizationType.values.firstWhere((element) => element.codeType ==
              type);
    }on StateError catch(exception, stacktrace) {
      // if not has a Type defined
    }
    coloCode = json['colorCode'];
    priority = json['priority'];
    if (json['contactDtoList'] != null) {
      contactList = [];
      json['contactDtoList'].forEach((v) {
        contactList!.add(Contact.fromJson(v));
      });
    }
    logoUrl = json['logoUrl'];
    typeDisplay = json['typeDisplay'];
    visibilityDisplay = json['visibilityDisplay'];
    visibility = json['visibility'];
    if( json['organizationSettings'] != null ){
      organizationSettings = OrganizationSettings.fromJson(json['organizationSettings']);
    }

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