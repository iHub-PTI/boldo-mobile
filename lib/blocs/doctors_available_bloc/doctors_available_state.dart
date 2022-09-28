part of 'doctors_available_bloc.dart';

@immutable
abstract class DoctorsAvailableState {}

class DoctorsAvailableInitial extends DoctorsAvailableState {}

class Loading extends DoctorsAvailableState {}

class Success extends DoctorsAvailableState {}
