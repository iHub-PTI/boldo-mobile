part of 'filter_bloc.dart';

@immutable
abstract class FilterState{}

class FilterInitial extends FilterState {}

class Loading extends FilterState {}

class Failed extends FilterState {
  final response;
  Failed({
    required this.response,
  });
}

class Success<T> extends FilterState {
  final T result;
  Success({
    required this.result,
  });
}