import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/blocs/family_bloc/dependent_family_bloc.dart' as family;
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
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

class _SingInTransitionState extends State<SingInTransition> with SingleTickerProviderStateMixin {

  bool _dataLoading = true;
  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  // controller to animate background
  late AnimationController _colorController;

  // pair of values for radialGradient
  late Animation<Color?> _color1Tween;
  late Animation<Color?> _color2Tween;
  late Animation<Color?> _color3Tween;
  late Animation<double?> _radiusTween;
  late Animation<double?> _stop1Tween;
  late Animation<double?> _stop2Tween;
  late Animation<double?> _stop3Tween;

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

    // initialize animation duration
    _colorController = AnimationController(
        duration: const Duration(milliseconds: 1700),
        vsync: this
    )..addListener(() {
      // change screen with animation
      setState(() {

      });
    });

    //initialize colors
    _color1Tween = ColorTween(
        begin: ConstantsV2.singInPrimaryColor100,
        end: ConstantsV2.singInSecondaryColor100)
        .animate(
          CurvedAnimation(parent: _colorController, curve: Curves.linear)
    );
    _color2Tween = ColorTween(
        begin: ConstantsV2.singInPrimaryColor200,
        end: ConstantsV2.singInSecondaryColor200)
        .animate(
          CurvedAnimation(parent: _colorController, curve: Curves.linear)
    );
    _color3Tween = ColorTween(
        begin: ConstantsV2.singInPrimaryColor300,
        end: ConstantsV2.singInSecondaryColor300)
        .animate(
          CurvedAnimation(parent: _colorController, curve: Curves.linear)
    );

    //initialize radius value
    _radiusTween = Tween<double?>(begin: .6, end: 1.7).animate(
        CurvedAnimation(parent: _colorController, curve: Curves.linear)
    );

    //initialize stopColors value
    _stop1Tween = Tween<double?>(begin: ConstantsV2.singInPrimaryStop100, end: ConstantsV2.singInSecondaryStop100).animate(
        CurvedAnimation(parent: _colorController, curve: Curves.linear)
    );
    _stop2Tween = Tween<double?>(begin: ConstantsV2.singInPrimaryStop200, end: ConstantsV2.singInSecondaryStop200).animate(
        CurvedAnimation(parent: _colorController, curve: Curves.linear)
    );
    _stop3Tween = Tween<double?>(begin: ConstantsV2.singInPrimaryStop300, end: ConstantsV2.singInSecondaryStop300).animate(
        CurvedAnimation(parent: _colorController, curve: Curves.linear)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PatientBloc, PatientState>(
        listener: (context, state){
            if(state is Failed){
              emitSnackBar(
                  context: context,
                  text: state.response,
                  status: ActionStatus.Fail
              );
              UserRepository().logout(context);
            }
            if(state is ChangeFamily){
              _dataLoading = false;

              //init animation
              _colorController.forward();

              _colorController..addStatusListener((status) {
                if(status == AnimationStatus.completed){
                  // go to home
                  Future.delayed(const Duration(
                    milliseconds: 800
                  )).then((value) => Navigator
                      .of(context).
                    pushNamedAndRemoveUntil(
                      '/home',
                      (Route<dynamic> route) => false
                    )
                  );
                }
              });
            }
            if(state is Loading){
              _dataLoading = true;
            }
          },
        child : Stack(
          children: [
            backGround(),
            BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state){
                if(state is ChangeFamily || state is RedirectNextScreen || state is Success) {
                  return
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Expanded(
                            child: Column(
                              children: [
                                Container(
                                  child: Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                                  Flexible(child: Text(
                                                    "${patient.givenName ?? ''}",
                                                    style: boldoBillboardTextStyleAlt
                                                        .copyWith(
                                                        color: ConstantsV2
                                                            .lightGrey
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),)
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                }else if(state is Loading){
                  return
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                            child: const LoadingHelper()
                        )
                    );
                }else{
                  return Container();
                }
              },
            ),
          ],
        )
      )
    );
  }

  Widget backGround(){
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: RadialGradient(
                  radius: _radiusTween.value?? 1,
                  center: const Alignment(
                    0,
                    0,
                  ),
                  colors: <Color>[
                    _color1Tween.value?? ConstantsV2.singInPrimaryColor200,
                    _color2Tween.value?? ConstantsV2.singInPrimaryColor200,
                    _color3Tween.value?? ConstantsV2.singInPrimaryColor300,
                  ],
                  stops: <double>[
                    _stop1Tween.value?? ConstantsV2.singInPrimaryStop100,
                    _stop2Tween.value?? ConstantsV2.singInPrimaryStop200,
                    _stop3Tween.value?? ConstantsV2.singInPrimaryStop300,
                  ]
              )
          ),
        ),
      ],
    );
  }

}
