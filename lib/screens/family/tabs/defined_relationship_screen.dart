import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/Relationship.dart';
import 'package:boldo/models/User.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:boldo/constants.dart';
import 'package:flutter_svg/svg.dart';

import '../../../main.dart';

class DefinedRelationshipScreen extends StatefulWidget {
  final bool setLoggedOut;

  DefinedRelationshipScreen({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _DefinedRelationshipScreenState createState() => _DefinedRelationshipScreenState();
}

class _DefinedRelationshipScreenState extends State<DefinedRelationshipScreen> {

  Response? response;
  bool _dataLoading = true;
  Patient? dependent;
  bool selected = false;
  Relationship? relationship;

  FlutterAppAuth appAuth = FlutterAppAuth();

  GlobalKey scaffoldKey = GlobalKey();

  Future _getFamiliesRelationship() async {

    //relationship =  relationTypes[0];
    //response = await dio.get("/profile/patient");
  }

  Future _getDependentDniInfo() async {
    dependent = Patient(
      givenName: user.givenName,
      familyName: user.familyName,
      gender: user.gender,
      identifier: user.identifier,
      photoUrl: user.photoUrl,
    );
  }

  @override
  void initState() {
    super.initState();

    _getFamiliesRelationship();
    _getDependentDniInfo();

    setState(() {
      _dataLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            const Background(text: "linkFamily"),
            SafeArea(
              child: BlocListener<PatientBloc, PatientState>(
                listener: (context, state){
                  setState(() {
                    if(state is Failed){
                      emitSnackBar(
                          context: context,
                          text: state.response,
                          status: ActionStatus.Fail
                      );
                      _dataLoading = false;
                    }
                    if(state is Success){
                    }
                    if(state is RedirectNextScreen){
                      Navigator.of(context).popUntil(ModalRoute.withName("/home"));
                    }
                    if(state is RedirectBackScreen){
                      Navigator.pop(context);
                    }
                    if(state is Loading){
                      _dataLoading = true;
                    }
                  });
                },
                child: BlocBuilder<PatientBloc, PatientState>(
                builder: (context, state) {
                  return Container(
                    child: Column(
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
                                            ProfileImageView2(height: 100, width: 100, border: true, patient: dependent),
                                          ],
                                        ),
                                        const SizedBox(height: 10,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              !_dataLoading ? user.givenName! + " " + user.familyName! : '',
                                              style: boldoTitleRegularTextStyle,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 40,),
                                      ]
                                  )
                              ),
                              _dataLoading? Container() :Container(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: DropdownButton<Relationship>(
                                    value: relationship,
                                    hint: Text(
                                      "¿Cuál es su relación con esta persona?",
                                      style: boldoSubTextMediumStyle.copyWith(
                                          color: ConstantsV2.activeText
                                      ),
                                    ),
                                    dropdownColor: ConstantsV2.lightGrey.withOpacity(0.5),
                                    style: boldoSubTextMediumStyle.copyWith(color: Colors.black),
                                    onChanged: (value) => setState(() {
                                      relationship = value!;
                                      user.relationshipCode = relationship!.code;
                                      selected = true;
                                    }),
                                    items: relationTypes
                                        .map((relationship) => DropdownMenuItem<Relationship>(
                                      child: Text(relationship.displaySpan!),
                                      value: relationship,
                                    )).toList(),
                                    isExpanded: true,

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          user = User();
                                          Navigator.of(context)
                                              .popUntil(ModalRoute.withName("/methods"));
                                        },
                                        child: const Text(
                                          "cancelar",
                                        ),
                                      ),
                                    ),
                                    AnimatedOpacity(
                                      opacity: selected ? 1 : 0,
                                      duration: const Duration(milliseconds: 300),
                                      child: Container(
                                        child: ElevatedButton(
                                          onPressed: selected ? () async {
                                            setState(() {
                                              user.relationshipCode = relationship!.code;
                                            });
                                            BlocProvider.of<PatientBloc>(context).add(LinkFamily());
                                          } : (){},
                                          child: const Text(
                                            "vincular",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            if(_dataLoading)
              Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: LoadingHelper()
                  )
              )
          ]
      ),
    );
  }


}
