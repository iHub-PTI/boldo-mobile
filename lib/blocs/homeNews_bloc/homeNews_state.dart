part of 'homeNews_bloc.dart';

@immutable
abstract class HomeNewsState{}

class HomeNewsInitial extends HomeNewsState {}

class LoadingNews extends HomeNewsState {}

class FailedLoadedNews extends HomeNewsState {
  final response;
  FailedLoadedNews({required this.response});
}

class NewsLoaded extends HomeNewsState {
  final List<News> news;
  NewsLoaded({required this.news});
}