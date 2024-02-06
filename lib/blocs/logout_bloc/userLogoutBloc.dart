import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


part 'userLogoutEvent.dart';
part 'userLogoutState.dart';


class UserLogoutBloc extends Bloc<UserLogoutEvent, UserLogoutState> {
  final  UserRepository _userRepository = UserRepository();
  UserLogoutBloc() : super(UserLogoutInitial()){
    on<UserLogoutEvent>((event, emit) async {
      if (event is GetUserLogout) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'POST',
          description: 'logout user',
          bindToScope: true,
        );
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          emit(UserLogoutSuccess());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      } else if (event is InitialEvent) {
        emit(UserLogoutInitial());
      }
    });
  }
}