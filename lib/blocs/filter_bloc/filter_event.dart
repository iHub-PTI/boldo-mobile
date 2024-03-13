part of 'filter_bloc.dart';

@immutable
abstract class FilterEvent {}

class ApplyFilter<T extends Filter> extends FilterEvent {
  final Filter filter;
  final Function(T filter) function;
  final BuildContext context;
  ApplyFilter({
    required this.filter,
    required this.function,
    required this.context,
  });
}