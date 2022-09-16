import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/blocs/family_bloc/dependent_family_bloc.dart' as family;
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:boldo/constants.dart';

import '../../main.dart';

class SingInTransition extends StatefulWidget {
  final bool setLoggedOut;

  SingInTransition({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _SingInTransitionState createState() => _SingInTransitionState();
}

class _SingInTransitionState extends State<SingInTransition> {

  Response? response;
  bool _dataLoading = true;
  Widget _background = const Background(text: "SingIn_1");
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  Future<void> timer() async {
    BlocProvider.of<family.FamilyBloc>(context).add(family.GetFamilyList());
    if(prefs.getBool(isFamily)?? false)
      BlocProvider.of<PatientBloc>(context).add(ChangeUser(id: prefs.getString("idFamily")));
    else
      BlocProvider.of<PatientBloc>(context).add(ChangeUser(id: null));
  }


  @override
  void initState() {
    timer();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PatientBloc, PatientState>(
        listener: (context, state){
            if(state is Failed){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response!),
                  backgroundColor: Colors.redAccent,
                ),
              );
              _dataLoading = false;
              Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (Route<dynamic> route) => false);
            }
            if(state is RedirectBackScreen){
              UserRepository().logout(context);
            }
            if(state is Success){
              _background = const Background(text: "SingIn_2");
              _dataLoading = false;
            }
            if(state is RedirectNextScreen){
              // go to home
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
            }
            if(state is Loading){
              _dataLoading = true;
            }
          },
        child : BlocBuilder<PatientBloc, PatientState>(
          builder: (context, state){
            if(state is ChangeFamily || state is RedirectNextScreen) {
              return Stack(
                children: [
                  _background,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      if(!_dataLoading) const ProfileImageView(
                                          height: 170,
                                          width: 170,
                                          border: true),
                                    ],
                                  ),
                                  const SizedBox(height: 29,),
                                  Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            _dataLoading ? Text('',
                                              style: boldoSubTextStyle
                                                  .copyWith(
                                                  color: ConstantsV2
                                                      .lightGrey
                                              ),) : Text(
                                              patient.gender == "unknown" ?
                                              "Bienvenido/a" :
                                              patient.gender == "male" ?
                                              "Bienvenido" : "Bienvenida",
                                              style: boldoSubTextStyle
                                                  .copyWith(
                                                  color: ConstantsV2
                                                      .lightGrey
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            Text(
                                              patient.givenName ?? '',
                                              style: boldoBillboardTextStyleAlt
                                                  .copyWith(
                                                  color: ConstantsV2
                                                      .lightGrey
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              );
            }else if(state is Loading){
              return
                Stack(
                  children: [
                    _background,
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                            child: const LoadingHelper()
                        )
                    ),
                  ],
                );
            }else{
              return Stack(
                children: [
                  _background,
                  Container(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

}
