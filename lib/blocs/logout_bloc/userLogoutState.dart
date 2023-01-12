part of 'userLogoutBloc.dart';

// definition of the principal class
@immutable
abstract class UserLogoutState {}

// definition of the different states
class UserLogoutInitial extends UserLogoutState{}
class UserLogoutLoading extends UserLogoutState{}
class UserLogoutSuccess extends UserLogoutState{}
class UserLogoutFailed extends UserLogoutState{
  final response;
  UserLogoutFailed({ required this.response });
}