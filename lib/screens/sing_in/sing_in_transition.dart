import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/cupertino.dart';
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
    if(prefs.getBool("isFamily")?? false)
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
          setState(() {
            if(state is Failed){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response!),
                  backgroundColor: Colors.redAccent,
                ),
              );
              _dataLoading = false;
            }
            if(state is Success){
              _dataLoading = false;
              Navigator.of(context).pushNamedAndRemoveUntil('/home', ModalRoute.withName('/onboarding'));
            }
            if(state is Loading){
              _dataLoading = true;
            }
          });
        },
        child : Stack(
          children: [
            _background,
            SafeArea(
              child: BlocBuilder<PatientBloc, PatientState>(
                builder: (context, state){
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                child :Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const ProfileImageView(height: 170, width: 170, border: true),
                                      ],
                                    ),
                                    const SizedBox(height: 29,),
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _dataLoading ? Text('Cargando',style: boldoSubTextStyle.copyWith(
                                                  color: ConstantsV2.lightGrey
                                              ),) :Text(
                                                patient.gender == "unknown" ?
                                                "Bienvenido/a" :
                                                patient.gender == "male" ?
                                                "Bienvenido" : "Bienvenida",
                                                style: boldoSubTextStyle.copyWith(
                                                    color: ConstantsV2.lightGrey
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                patient.givenName ?? '',
                                                style: boldoBillboardTextStyleAlt.copyWith(
                                                    color: ConstantsV2.lightGrey
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
                    ),
                  );
                },
              ),
            ),
            if(_dataLoading)
              Align(
                alignment: Alignment.center,
                child: Container(
                  child: const LoadingHelper()
                )
              )
          ]
        ),
      ),
    );
  }

}
