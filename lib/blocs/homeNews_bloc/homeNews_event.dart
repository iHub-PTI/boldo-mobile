part of 'homeNews_bloc.dart';

@immutable
abstract class HomeNewsEvent {}

class GetNews extends HomeNewsEvent {}

class DeleteNews extends HomeNewsEvent {
  final News news;
  DeleteNews({required this.news});
}
