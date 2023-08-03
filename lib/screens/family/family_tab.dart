import 'package:boldo/blocs/family_bloc/dependent_family_bloc.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/family/components/family_rectagle_card.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:boldo/constants.dart';

import '../../main.dart';
import '../../utils/loading_helper.dart';

class FamilyScreen extends StatefulWidget {

  FamilyScreen({Key? key}) : super(key: key);

  @override
  _FamilyScreenState createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  bool _loading = false;

  double familySpacingCards = 8;

  @override
  void initState() {
    BlocProvider.of<FamilyBloc>(context).add(GetFamilyList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [],
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
          SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: BlocListener<FamilyBloc, FamilyState>(
        listener: (context, state){
          if(state is Success) {
            setState(() {
              _loading = false;
            });
          }else if(state is Failed){
            emitSnackBar(
                context: context,
                text: state.response,
                status: ActionStatus.Fail
            );
            _loading = false;
          }else if(state is Loading){
            setState(() {
              _loading = true;
            });
          }else if(state is DependentEliminated){
            emitSnackBar(
                context: context,
                text: "Familiar desvinculado",
                status: ActionStatus.Success
            );
          }
      },
      child: BlocBuilder<FamilyBloc, FamilyState>(
        builder: (context, state) {
          return Stack(children: [
            const Background(text: "family"),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BackButtonLabel(
                            labelText: 'Mi Familia',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width-16,
                                  child: Column(children: [
                                    const FamilyRectangleCard(isDependent: false)
                                  ])),
                              Container(
                                height: MediaQuery.of(context).size.height * 0.60,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.topLeft,
                                child: families.length > 0
                                    ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: families.length,
                                  padding: const EdgeInsets.all(8),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: _buildItem,
                                )
                                    : const EmptyStateV2(
                                  picture: "Helping old man 1.svg",
                                  textBottom:
                                  "Aún no agregaste ningún perfil para gestionar",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/methods');
                              },
                              child: Text(families.length > 0
                                  ? "nuevo miembro"
                                  : "agregar"),
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
            if(_loading)
              Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: const LoadingHelper()
                  )
              ),
          ]);
        }),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return Container(
      padding: EdgeInsets.only(bottom: familySpacingCards),
      child: FamilyRectangleCard(
        patient: families[index],
        isDependent: true,
      ),
    );
  }
}
