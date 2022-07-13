import 'package:boldo/blocs/homeAppointments_bloc/homeAppointments_bloc.dart';
import 'package:boldo/blocs/homeNews_bloc/homeNews_bloc.dart';
import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
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

class _FamilyTransitionState extends State<FamilyTransition> {

  Response? response;
  bool _dataLoading = true;
  Widget _background = const Background(text: "SingIn_1");
  FlutterAppAuth appAuth = FlutterAppAuth();
  GlobalKey scaffoldKey = GlobalKey();

  Future<void> timer() async {
    if(prefs.getBool(isFamily)?? false)
      BlocProvider.of<PatientBloc>(context).add(ChangeUser(id: prefs.getString("idFamily")));
    else
      BlocProvider.of<PatientBloc>(context).add(ChangeUser(id: null));
  }


  @override
  void initState() {
    super.initState();
    timer();

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
              final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
              //set previous value
              prefs.setBool(isFamily, arguments[isFamily]);
              Navigator.pop(context);
              _dataLoading = false;
            }
            if(state is Success){
              _dataLoading = false;
              BlocProvider.of<HomeAppointmentsBloc>(context).add(GetAppointmentsHome());
              BlocProvider.of<HomeNewsBloc>(context).add(GetNews());
            }
            if(state is RedirectNextScreen){
              // back to home
              Navigator.of(context).popUntil(ModalRoute.withName('/home'));
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
                                          if(!_dataLoading)
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
                                                    "${patient.givenName ?? ''}${patient.familyName ?? ''}",
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
