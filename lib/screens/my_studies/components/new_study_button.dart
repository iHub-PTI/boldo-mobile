import 'package:boldo/constants.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:boldo/screens/my_studies/new_study.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class NewStudyButton extends StatefulWidget {

  final TabController? listener;


  NewStudyButton({this.listener });

  @override
  State<NewStudyButton> createState() => _NewStudyButtonState();

}

class _NewStudyButtonState extends State<NewStudyButton>{

  bool showButton = false;

  @override
  void initState(){
    widget.listener?.addListener(() {
      showButton = widget.listener?.index == 1;
      setState(() {

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){

    return AnimatedCrossFade(
      firstChild: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

      ],),
      secondChild: ElevatedButton(
        onPressed: () {
          if(BlocProvider.of<MyStudiesBloc>(context).state is Loading){
            emitSnackBar(
              context: context,
              text: "Favor aguardar durante la carga.",
              status: ActionStatus.Fail,
            );
          }else{
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => NewStudy()
                )
            );
          }
        },
        child: BlocBuilder<MyStudiesBloc, MyStudiesState>(
          builder: (BuildContext context, state) {
            if(state is Loading){
              return loadingStatus();
            }else{
              return Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'nuevo resultado',
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SvgPicture.asset(
                        'assets/icon/upload.svg',
                      ),
                    ],
                  )
              );
            }
          },
        ),
      ),
      crossFadeState: showButton? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: Duration(milliseconds: 500),
    );
  }


}