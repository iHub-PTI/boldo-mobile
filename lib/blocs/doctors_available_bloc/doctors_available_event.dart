part of 'doctors_available_bloc.dart';

@immutable
abstract class DoctorsAvailableEvent {}


class GetDoctorsAvailable extends DoctorsAvailableEvent {}
class ReloadDoctorsAvailable extends DoctorsAvailableEvent {}