part of 'studiesOrders_bloc.dart';

@immutable
abstract class StudiesOrdersState {}

class StudiesOrdersInitial extends StudiesOrdersState {}

class LoadingOrders extends StudiesOrdersState {}

class FailedLoadedOrders extends StudiesOrdersState {
  final response;
  FailedLoadedOrders({required this.response});
}

class StudiesOrdersLoaded extends StudiesOrdersState {
  final List<ServiceRequest> studiesOrders;
  StudiesOrdersLoaded({required this.studiesOrders});
}

