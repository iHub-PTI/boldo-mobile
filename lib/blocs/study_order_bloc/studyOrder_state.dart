part of 'studyOrder_bloc.dart';

@immutable
abstract class StudyOrderState{}

class StudiesOrderInitial extends StudyOrderState {}

class LoadingOrders extends StudyOrderState {}

class FailedLoadedOrders extends StudyOrderState {
  final response;
  FailedLoadedOrders({required this.response});
}

class StudiesLoaded extends StudyOrderState {
  final List<StudyOrder> studiesOrder;
  StudiesLoaded({required this.studiesOrder});
}