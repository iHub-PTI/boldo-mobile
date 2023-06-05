import 'package:boldo/blocs/homeAppointments_bloc/homeAppointments_bloc.dart';
import 'package:boldo/blocs/homeNews_bloc/homeNews_bloc.dart';
import 'package:boldo/blocs/homeOrganization_bloc/homeOrganization_bloc.dart';
import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:boldo/constants.dart';

import '../../../main.dart';


class FamilyTransition extends StatefulWidget {
  final bool setLoggedOut;

  FamilyTransition({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _FamilyTransitionState createState() => _FamilyTransitionState();
}

class _FamilyTransitionState extends State<FamilyTransition> with SingleTickerProviderStateMixin {

  Response? response;
  bool _dataLoading = true;
  FlutterAppAuth appAuth = FlutterAppAuth();
  GlobalKey scaffoldKey = GlobalKey();

  // controller to animate background
  late AnimationController _colorController;

  Future<void> timer() async {
    if(prefs.getBool(isFamily)?? false)
      BlocProvider.of<PatientBloc>(context).add(ChangeUser(id: prefs.getString("idFamily")));
    else
      BlocProvider.of<PatientBloc>(context).add(ChangeUser(id: null));
  }


  @override
  void initState() {
    super.initState();
    // initialize animation duration
    _colorController = AnimationController(
        duration: const Duration(milliseconds: 1700),
        vsync: this
    );
    timer();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PatientBloc, PatientState>(
        listener: (context, state){
          setState(() {
            if(state is Failed){
              emitSnackBar(
                  context: context,
                  text: state.response,
                  status: ActionStatus.Fail
              );
              final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
              //set previous value
              prefs.setBool(isFamily, arguments[isFamily]);
              Navigator.pop(context);
              _dataLoading = false;
            }
            if(state is Success){
              _dataLoading = false;
              BlocProvider.of<HomeOrganizationBloc>(context).add(GetOrganizationsSubscribed());
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
          });
        },
        child : Stack(
            children: [
              if(prefs.getBool(isFamily)?? false)
                BackgroundRadialGradientTransition(
                    initialColors: [ConstantsV2.familyConnectPrimaryColor100, ConstantsV2.familyConnectPrimaryColor200, ConstantsV2.familyConnectPrimaryColor300,],
                    finalColors: [ConstantsV2.familyConnectSecondaryColor100, ConstantsV2.familyConnectSecondaryColor200, ConstantsV2.familyConnectSecondaryColor300,],
                    initialStops: [ConstantsV2.familyConnectPrimaryStop100, ConstantsV2.familyConnectPrimaryStop200, ConstantsV2.familyConnectPrimaryStop300,],
                    finalStops: [ConstantsV2.familyConnectSecondaryStop100, ConstantsV2.familyConnectSecondaryStop200, ConstantsV2.familyConnectSecondaryStop300,],
                    initialRadius: .5,
                    finalRadius: .6,
                    animationController: _colorController
                )
              else
                BackgroundRadialGradientTransition(
                    initialColors: [ConstantsV2.singInPrimaryColor100, ConstantsV2.singInPrimaryColor200, ConstantsV2.singInPrimaryColor300,],
                    finalColors: [ConstantsV2.singInSecondaryColor100, ConstantsV2.singInSecondaryColor200, ConstantsV2.singInSecondaryColor300,],
                    initialStops: [ConstantsV2.singInPrimaryStop100, ConstantsV2.singInPrimaryStop200, ConstantsV2.singInPrimaryStop300,],
                    finalStops: [ConstantsV2.singInSecondaryStop100, ConstantsV2.singInSecondaryStop200, ConstantsV2.singInSecondaryStop300,],
                    initialRadius: .6,
                    finalRadius: 1.7,
                    animationController: _colorController
                ),
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
                                          if(!_dataLoading)
                                            ImageViewTypeForm(
                                              height: 170,
                                              width: 170,
                                              border: true,
                                              url: patient.photoUrl,
                                              gender: patient.gender,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 29,),
                                      Container(
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _dataLoading ? Text('',style: boldoSubTextStyle.copyWith(
                                                    color: ConstantsV2.lightGrey
                                                ),) :
                                                prefs.getBool(isFamily)?? false ?
                                                Flexible(child:Text(
                                                  "Mostrando datos de",
                                                  textAlign: TextAlign.center,
                                                  style: boldoSubTextStyle.copyWith(
                                                      color: ConstantsV2.lightGrey
                                                  ),
                                                ),)
                                                :
                                                Text(
                                                  "Ahora mostrando",
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
                                                if(!_dataLoading)
                                                prefs.getBool(isFamily)?? false ?
                                                Flexible(
                                                  child: Text(
                                                    "${patient.givenName ?? ''} ${patient.familyName ?? ''}",
                                                    textAlign: TextAlign.center,
                                                    style: boldoBillboardTextStyleAlt.copyWith(
                                                        color: ConstantsV2.lightGrey
                                                    ),
                                                  ),
                                                ):
                                                Flexible(
                                                  child: Text(
                                                    "mis datos",
                                                    style: boldoBillboardTextStyleAlt.copyWith(
                                                        color: ConstantsV2.lightGrey
                                                    ),
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
