part of 'userLoginBloc.dart';

// definition of the principal class
@immutable
abstract class UserLoginState {}

// definition of the different states
class UserLoginInitial extends UserLoginState{}
class UserLoginLoading extends UserLoginState{}
class UserLoginSuccess extends UserLoginState{}
class UserLoginFailed extends UserLoginState{
  final response;
  UserLoginFailed({ required this.response });
}