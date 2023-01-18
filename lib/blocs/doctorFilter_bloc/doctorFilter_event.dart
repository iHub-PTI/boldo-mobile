part of 'doctorFilter_bloc.dart';

@immutable
abstract class DoctorFilterEvent {}

class GetDoctorsPreview extends DoctorFilterEvent {
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  GetDoctorsPreview({
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
}

