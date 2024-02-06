import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'userLogoutEvent.dart';
part 'userLogoutState.dart';


class UserLogoutBloc extends Bloc<UserLogoutEvent, UserLogoutState> {
  final  UserRepository _userRepository = UserRepository();
  UserLogoutBloc() : super(UserLogoutInitial()){
    on<UserLogoutEvent>((event, emit) async {
      if (event is GetUserLogout) {
        emit(UserLogoutLoading());
        var _post;
        await Task(() =>
        _userRepository.logout(event.context)!)
        .attempt()
        .mapLeftToFailure()
        .run()
        .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(UserLogoutFailed(response: response));
        } else {
          emit(UserLogoutSuccess());
        }
      } else if (event is InitialEvent) {
        emit(UserLogoutInitial());
      }
    });
  }
}