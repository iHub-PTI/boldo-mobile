part of 'userLoginBloc.dart';


@immutable
abstract class UserLoginEvent {}

class UserLogin extends UserLoginEvent{
  final BuildContext context;
  UserLogin({ required this.context });
}