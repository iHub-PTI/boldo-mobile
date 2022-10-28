import 'package:boldo/blocs/family_bloc/dependent_family_bloc.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/family/components/caretaker_rectangle_card.dart';
import 'package:boldo/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:boldo/constants.dart';

import 'QR_generator.dart';

class MyManagersTab extends StatefulWidget {
  final bool setLoggedOut;

  MyManagersTab({Key? key, this.setLoggedOut = false}) : super(key: key);

  @override
  _MyManagersTabState createState() => _MyManagersTabState();
}

class _MyManagersTabState extends State<MyManagersTab> {

  List<Patient> managers = [
  ];

  bool _dataLoading = true;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FamilyBloc>(context).add(GetManagersList());
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
          if(state is CaretakersObtained) {
            managers = state.caretakers;
            setState(() {
              _dataLoading = false;
            });
          }else if(state is Failed){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response!),
                backgroundColor: Colors.redAccent,
              ),
            );
            _dataLoading = false;
          }else if(state is Loading){
            setState(() {
              _dataLoading = true;
            });
          }
        },
        child: BlocBuilder<FamilyBloc, FamilyState>(
          builder: (context, state) {
            return Stack(
              children: [
                const Background(text: "family"),
                SafeArea(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                icon: SvgPicture.asset(
                                  'assets/icon/chevron-left.svg',
                                  color: ConstantsV2.activeText,
                                ),
                              ),
                              const Text(
                                "Mis gestores",
                                style: boldoTitleBlackTextStyle,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.topLeft,
                                child: managers.length > 0 
                                  ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: managers.length,
                                    padding: const EdgeInsets.all(8),
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: _buildItem,
                                  ) 
                                  : _dataLoading
                                    ? Container()
                                    : const EmptyStateV2(picture: "Helping old man 1.svg", textBottom: "aún no tienes ningún gestor"),
                              ),
                            ],
                          ),
                        ),
                        managers.length > 0 
                          ? Container()
                          : _dataLoading 
                            ? Container() 
                            : Container(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              child: const Text("Aquí apareceran las personas a quienes des "
                                "permiso como gestor. Esto significa que van a poder "
                                "ver tu historia clinica y realizar gestiones como "
                                "marcar y cancelar consultas en tu nombre, entre otras "
                                "funciones"
                            ),
                          ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => const QRGenerator()
                                          ));
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text("vincular con QR"),
                                            const SizedBox(width: 10,),
                                            SvgPicture.asset(
                                              'assets/icon/qrcode.svg',
                                              color: ConstantsV2.lightGrey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            );
          }
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index){
    return CaretakerRectangleCard(patient: managers[index], isDependent: true,);
  }

}
