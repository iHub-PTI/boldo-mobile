import 'package:boldo/constants.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/filters/Filter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Applied filter for doctors
class DoctorFilter extends Filter {
  /// Applied filter for doctors
  DoctorFilter({
    required List<Specializations> specializationsApplied,
    required List<Organization> organizationsApplied,
    required List<String> selectedNamesApplied,
    bool virtualAppointmentApplied = false,
    bool inPersonAppointmentApplied = false,
  }) {
    _specializationsApplied = specializationsApplied;
    _organizationsApplied = organizationsApplied;
    _selectedNamesApplied = selectedNamesApplied;
    _virtualAppointmentApplied = virtualAppointmentApplied;
    _inPersonAppointmentApplied = inPersonAppointmentApplied;
  }

  // variables containing the last applied filter
  List<Specializations> _specializationsApplied = [];
  List<Organization> _organizationsApplied = [];
  List<String> _selectedNamesApplied = [];
  bool _virtualAppointmentApplied = false;
  bool _inPersonAppointmentApplied = false;

  /// get the last specializations applied.
  List<Specializations> get getSpecializationsApplied =>
      _specializationsApplied;

  /// get the last organizations applied.
  List<Organization> get getOrganizationsApplied => _organizationsApplied;

  /// get the last names applied.
  List<String> get getNamesApplied => _selectedNamesApplied;
  bool get getLastVirtualAppointmentApplied => _virtualAppointmentApplied;
  bool get getLastInPersonAppointmentApplied => _inPersonAppointmentApplied;

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json;

    String? appointmentType;
    // here set the type of appointment
    if (_virtualAppointmentApplied && _inPersonAppointmentApplied) {
      appointmentType = 'AV';
    } else if (_virtualAppointmentApplied) {
      appointmentType = 'V';
    } else if (_inPersonAppointmentApplied) {
      appointmentType = 'A';
    }

    // list of organizations IDs
    final listOfOrganizations =
        _organizationsApplied.map((e) => e.id!).toList().join(',');

    // list of names split for spaces
    final listOfNames = _selectedNamesApplied.join(' ');

    return {
      'appointmentType': appointmentType,
      'specialtyIds': _specializationsApplied.map((e) => e.id!).toList(),
      'organizations': listOfOrganizations == '' ? null : listOfOrganizations,
      'names': listOfNames.split(' '),
    }..removeWhere((key, value) => value == null);
  }

  @override
  Future<void> clearFilter() async {
    _specializationsApplied = [];
    _organizationsApplied = [];
    _selectedNamesApplied = [];
    _virtualAppointmentApplied = false;
    _inPersonAppointmentApplied = false;
  }

  @override
  bool get ifFiltered {
    return _specializationsApplied.isNotEmpty ||
        _organizationsApplied.isNotEmpty ||
        _selectedNamesApplied.isNotEmpty ||
        _virtualAppointmentApplied ||
        _inPersonAppointmentApplied;
  }

  @override
  bool operator ==(Object other) {
    const eq = DeepCollectionEquality.unordered();
    if (other is DoctorFilter) {
      return _inPersonAppointmentApplied ==
              other.getLastInPersonAppointmentApplied &&
          _virtualAppointmentApplied ==
              other.getLastVirtualAppointmentApplied &&
          eq.equals(getNamesApplied, other.getNamesApplied) &&
          eq.equals(getOrganizationsApplied, other.getOrganizationsApplied) &&
          eq.equals(getSpecializationsApplied, other.getSpecializationsApplied);
    } else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hashAll(
        [
          getNamesApplied,
          getOrganizationsApplied,
          getSpecializationsApplied,
          getLastInPersonAppointmentApplied,
          getLastVirtualAppointmentApplied,
        ],
      );

  DoctorFilter copyWith({
    List<Specializations>? specializationsApplied,
    List<Organization>? organizationsApplied,
    List<String>? selectedNamesApplied,
    bool? virtualAppointmentApplied,
    bool? inPersonAppointmentApplied,
  }) =>
      DoctorFilter(
        specializationsApplied:
            specializationsApplied ?? _specializationsApplied,
        organizationsApplied: organizationsApplied ?? _organizationsApplied,
        selectedNamesApplied: selectedNamesApplied ?? _selectedNamesApplied,
        inPersonAppointmentApplied:
            inPersonAppointmentApplied ?? _inPersonAppointmentApplied,
        virtualAppointmentApplied:
            virtualAppointmentApplied ?? _virtualAppointmentApplied,
      );

  @override
  Map<Widget, Function()> get filters {
    final filters = <Widget, Function()>{};

    if (_inPersonAppointmentApplied || _virtualAppointmentApplied) {
      final child = Row(
        children: [
          SvgPicture.asset(
            'assets/icon/in_person.svg',
            color: _inPersonAppointmentApplied
                ? ConstantsV2.primaryRegular
                : ConstantsV2.blueLight,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
          ),
          SvgPicture.asset(
            'assets/icon/videocam.svg',
            color: _virtualAppointmentApplied
                ? ConstantsV2.secondaryRegular
                : ConstantsV2.blueLight,
          ),
        ],
      );

      void removeAppointmentTypeFilter() {
        _inPersonAppointmentApplied = false;
        _virtualAppointmentApplied = false;
      }

      filters.addAll({child: removeAppointmentTypeFilter});
    }

    if (_organizationsApplied.isNotEmpty) {
      for (final organization in _organizationsApplied) {
        final organizationName = Text(organization.name ?? '');
        void removeOrganization() {
          _organizationsApplied.remove(organization);
        }

        filters.addAll({organizationName: removeOrganization});
      }
    }

    if (_specializationsApplied.isNotEmpty) {
      for (final specialization in _specializationsApplied) {
        final specializationName = Text(specialization.description ?? '');
        void removeOrganization() {
          _specializationsApplied.remove(specialization);
        }

        filters.addAll({specializationName: removeOrganization});
      }
    }

    if (_selectedNamesApplied.isNotEmpty) {
      for (final nameSelected in _selectedNamesApplied) {
        final name = Text(nameSelected);
        void removeName() {
          _selectedNamesApplied.remove(nameSelected);
        }

        filters.addAll({name: removeName});
      }
    }

    return filters;
  }
}
