import 'package:boldo/blocs/login_bloc/userLoginBloc.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants.dart';

class LoginWebViewHelper extends StatefulWidget {
  const LoginWebViewHelper({Key? key}) : super(key: key);

  @override
  _LoginWebViewHelperState createState() => _LoginWebViewHelperState();
}

class _LoginWebViewHelperState extends State<LoginWebViewHelper> {

  UserLoginBloc _userLoginBloc = UserLoginBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserLoginBloc>(
      create: (BuildContext newContext) {
        return _userLoginBloc..add(UserLogin(context: context));
      },
      lazy: false,
      child: Container(
        color: Constants.grayColor50,
        child: loadingStatus(),
      ),
    );
  }

}

