part of 'filter_bloc.dart';

@immutable
abstract class FilterEvent {}

class ApplyFilter extends FilterEvent {
  final Filter filter;
  final Function(Filter filter) function;
  final BuildContext context;
  ApplyFilter({
    required this.filter,
    required this.function,
    required this.context,
  });
}