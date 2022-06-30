part of 'my_studies_bloc.dart';

@immutable
abstract class MyStudiesEvent {}

class GetPatientStudiesFromServer extends MyStudiesEvent {}