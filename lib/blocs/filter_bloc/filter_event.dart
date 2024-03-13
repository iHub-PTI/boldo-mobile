part of 'filter_bloc.dart';

@immutable
abstract class FilterEvent {}

class ApplyFilter extends FilterEvent {
  final Filter filter;
  final Function(Filter filter) function;
  ApplyFilter({
    required this.filter,
    required this.function,
  });
}