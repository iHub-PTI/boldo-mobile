part of 'studyOrder_bloc.dart';

@immutable
abstract class StudyOrderEvent {}

class GetNews extends StudyOrderEvent {}

class GetNewsId extends StudyOrderEvent {
  final String encounter;
  GetNewsId({required this.encounter});
}

class InitialEventStudyOrder extends StudyOrderEvent {}