import 'package:boldo/blocs/user_bloc/patient_bloc.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/screens/profile/profile_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';

import '../../../../main.dart';
import '../../menu.dart';

class HomeTabAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double max;
  const HomeTabAppBar({
    Key? key,
    required this.max,
  }) : super(key: key);

  @override
  _HomeTabAppBarState createState() => _HomeTabAppBarState(max);
  @override
  Size get preferredSize => const Size.fromHeight(110);
}

class _HomeTabAppBarState extends State<HomeTabAppBar> {

  _HomeTabAppBarState(this.max);
  double max;
  Response? response;
  bool _dataLoading = true;
  var expanded = true ;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  Future _getProfileData() async {

    setState(() {
      _dataLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    expanded = widget.max > (ConstantsV2.homeAppBarMaxHeight+ConstantsV2.homeAppBarMinHeight)/2;
    return Container(
      constraints: BoxConstraints(maxHeight: widget.max, minHeight: widget.max),
      height: widget.max,
      decoration: _decoration(),
      child: BlocListener<PatientBloc, PatientState>(
        listener: (context, state){
          setState(() {
            if(state is Failed){
              _dataLoading = false;
            }
            if(state is Success){
              _dataLoading = false;
            }
            if(state is Loading){
              _dataLoading = true;
            }
          });
        },
        child: BlocBuilder<PatientBloc, PatientState>(
          builder: (context, state) {
            return Row(
              children: [
                const SizedBox(width: 10),
                GestureDetector(
                  /*onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },*/
                  child: ProfileImageView(height: expanded ? 100 : 60,
                      width: expanded ? 100 : 60,
                      border: true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(prefs.getBool("isFamily")!)
                        Flexible(
                          child: Text(
                            "mostrando a",
                            style: boldoCorpMediumTextStyle.copyWith(
                                color: ConstantsV2.lightGrey
                            ),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          "${patient.givenName ?? ''}${patient.familyName ??
                              ''}",
                          style: boldoCardHeadingTextStyle.copyWith(
                              color: ConstantsV2.lightest
                          ),
                        ),
                      ),
                      SizedBox(height: (widget.max /
                          ConstantsV2.homeAppBarMaxHeight) * 10),
                      if(! prefs.getBool("isFamily")!)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              patient.city ?? '',
                              style: expanded
                                  ? boldoCorpMediumTextStyle
                                  : boldoCorpSmallTextStyle,
                            ),
                          ]
                        ),

                      const SizedBox(height: 4),
                      !prefs.getBool("isFamily")! ?Text(
                        formatDate(
                          DateTime.now(),
                          [d, ' de ', MM, ' de ', yyyy],
                          locale: const SpanishDateLocale(),
                        ),
                        style: expanded
                            ? boldoCorpMediumTextStyle
                            : boldoCorpSmallTextStyle,
                      ): Flexible(
                        child: Text(
                          "${patient.relationshipDisplaySpan?? ''}",
                          style: boldoCorpMediumTextStyle.copyWith(
                              color: ConstantsV2.lightGrey
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) => MenuScreen()));
                      },
                      icon: SvgPicture.asset(
                        'assets/icon/menu-alt-1.svg',
                        color: ConstantsV2.lightest,
                      ),
                    ),
                    families.length != 0 ? Container(
                      constraints: const BoxConstraints(
                          maxHeight: 33, maxWidth: 33),
                      margin: const EdgeInsets.all(16),
                      child: FloatingActionButton(
                        onPressed: () {
                          _showFamilyBox();
                        },
                        backgroundColor: ConstantsV2.orange,
                        child: SvgPicture.asset('assets/icon/family.svg'),
                        elevation: 0,
                      ) ,
                    ) : Container(),
                  ],
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  _showFamilyBox(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool expand = false;
        double start = 0;
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsetsDirectional.all(0),
              scrollable: true,
              backgroundColor: ConstantsV2.lightGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Container(
                width: 330,
                height: expand ? 375 : 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    !expand
                    ? Container(
                      height: 55,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      width: 305,
                      alignment: Alignment.topLeft,
                      child: families.length > 0 ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: families.length + 2,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: _buildPictureRoundedFamily,
                      ) : Container(),
                    ) :
                    Container(
                      width: 305,
                      height: 250,
                      alignment: Alignment.topLeft,
                      child: families.length > 0 ? GridView.builder(
                        shrinkWrap: true,
                        itemCount: families.length + 2,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        scrollDirection: Axis.vertical,
                        itemBuilder:  _buildPictureSquareFamily,
                      ) : Container(),
                    ),
                    Listener(
                      onPointerDown: (PointerDownEvent event) {
                        setState ((){
                          start = event.localPosition.dy;
                          print("Down ${start}");
                        });
                      },
                      onPointerUp: (PointerUpEvent event) {
                        setState ((){
                          print("UP ${event.localPosition.dy}");
                          if(start < event.localPosition.dy)
                            expand = true;
                          else if( start > event.localPosition.dy )
                            expand = false;
                        });
                      },
                      child: Container(
                        height: expand? 55: 20,
                        width: 200,
                        color: ConstantsV2.lightGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            expand? OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/familyScreen');
                                },
                                child: const Text("más opciones")
                            ) : Container(),
                            Container(
                              width: 55,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: ConstantsV2.inactiveText,
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  ]
                ),
              ),
            );
          },

        );
      }
    );
  }

  Widget _buildPictureRoundedFamily(BuildContext context, int index){
    return _profileFamily(index, "rounded");
  }

  Widget _buildPictureSquareFamily(BuildContext context, int index){
    return _profileFamily(index, "square");
  }

  Widget _profileFamily(int index, String type){
    double height = type == "rounded"? 54 : 85;
    double width = type == "rounded"? 54 : 120;
    return Container(
      constraints: const BoxConstraints(maxHeight: 125, maxWidth: 120),
      child: GestureDetector(
        child: type == "square"? Column(
          children: [
            index <= families.length ?
              index == 0
                ? InkWell(
                  onTap: () {
                    prefs.remove("idFamily");
                    prefs.setBool("isFamily", false);
                    Navigator.pushNamed(context, '/FamilyTransition');
                  },
                  child:ProfileImageViewTypeForm(height: height, width: width, border: false, form: type,)
                )
                :InkWell(
                  onTap: () {
                    prefs.setString("idFamily", families[index-1].id!);
                    prefs.setBool("isFamily", true);
                    Navigator.pushNamed(context, '/FamilyTransition');
                  },
                  child:ProfileImageViewTypeForm(height: height, width: width, border: false, patient: families[index-1], form: type,)
                )
              : InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/methods');
                },
                child: SvgPicture.asset('assets/icon/family-add.svg', height: height, width: width,),
              ),

            index <= families.length ?
              index == 0
                ? Text("Yo", style: boldoCorpMediumTextStyle.copyWith(color: ConstantsV2.activeText),)
                :Text(families[index-1].relationshipDisplaySpan!, style: boldoCorpMediumTextStyle.copyWith(color: ConstantsV2.activeText),)
              :Text("agregar", style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.green),),

            index <= families.length ?
              index == 0
                ? Container()
                :Text("${families[index-1].givenName?? ''} ${families[index-1].familyName?? ''}", style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.green),)
                : Container(),
          ],
        )
        :index <= families.length ?
          index == 0
            ? InkWell(
              onTap: () {
                prefs.remove("idFamily");
                prefs.setBool("isFamily", false);
                Navigator.pushNamed(context, '/FamilyTransition');
              },
              child: ProfileImageViewTypeForm(height: height, width: width, border: false, form: type,)
            )
            :InkWell(
              onTap: () {
                prefs.setString("idFamily", families[index-1].id!);
                prefs.setBool("isFamily", true);
                Navigator.pushNamed(context, '/FamilyTransition');
              },
              child: ProfileImageViewTypeForm(height: height, width: width, border: false, patient: families[index-1], form: type,)
            )
          :InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/methods');
            },
            child: SvgPicture.asset('assets/icon/family-add.svg', height: height, width: width,),
          ),

        onTap: null,
      ),
    );
  }

  BoxDecoration _decoration(){
    if((prefs.getBool("isFamily")?? false)){
      return const BoxDecoration(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
          gradient: RadialGradient(
              radius: 4,
              center: Alignment(
                1.80,
                0.77,
              ),
              colors: <Color>[
                ConstantsV2.familyAppBarColor100,
                ConstantsV2.familyAppBarColor200,
                ConstantsV2.familyAppBarColor200,
              ],
              stops: <double>[
                ConstantsV2.familyAppBarStop100,
                ConstantsV2.familyAppBarStop200,
                ConstantsV2.familyAppBarStop300,
              ]
          )
      );
    }else{
      return const BoxDecoration(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
          gradient: RadialGradient(
              radius: 4,
              center: Alignment(
                1.80,
                0.77,
              ),
              colors: <Color>[
                ConstantsV2.patientAppBarColor100,
                ConstantsV2.patientAppBarColor200,
                ConstantsV2.patientAppBarColor300,
              ],
              stops: <double>[
                ConstantsV2.patientAppBarStop100,
                ConstantsV2.patientAppBarStop200,
                ConstantsV2.patientAppBarStop300,
              ]
          )
      );
    }
  }

}
