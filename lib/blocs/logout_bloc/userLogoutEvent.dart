part of 'userLogoutBloc.dart';


@immutable
abstract class UserLogoutEvent {}


class InitialEvent extends UserLogoutEvent{}
class GetUserLogout extends UserLogoutEvent{
  final BuildContext context;
  GetUserLogout({ required this.context });
}