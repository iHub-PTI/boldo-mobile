import 'package:boldo/constants.dart';
import 'package:boldo/screens/organizations/memberships_screen.dart';
import 'package:boldo/screens/pharmacy/pharmacy_availables.dart';
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['type'] = type;
    data['value'] = value;
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
      codeType: 'HOSPITAL'
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