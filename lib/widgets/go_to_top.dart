import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// THIS BUTTON YOU MUST USE INTO floatingActionButton IN A Scaffold

/* 
  To use this widget you must follow the instructions below

  ***** in your state of StatefulWidget *****
  you must create a controller for the scroll with this code line

  // the scrollable controller
  ScrollController "nameOfYourController" = ScrollController();
  // flag for show or not the button
  bool showAnimatedButton = false;


  ***** in your initState function *****
  "nameOfYourController".addListener(() {
    double offset = 10.0; // or the value you want
    if ("nameOfYourController".offset > offset){
      showAnimatedButton = true;
      // this we use to get update the state
      setState((){

      });
    } else {
      showAnimatedButton = false;
      setState((){

      });
    }
  });
  super.initState();


  ***** in your listview or gridview or any similar structure *****
  // controller is a Scroll Controller
  controller = "nameOfYourController"

*/



// animationDuration usually use 1000 milisends
// scrollDuration usually use 500 miliseconds
Widget buttonGoTop(ScrollController scrollController,
    int animationDuration, int scrollDuration, bool showAnimatedButton) {
  return AnimatedOpacity(
    duration: Duration(milliseconds: animationDuration),
    opacity: showAnimatedButton ? 1.0 : 0.0, // 1 is to get visible
    child: FloatingActionButton(
      onPressed: () {
        scrollController.animateTo(0, // to go to top
            duration: Duration(microseconds: scrollDuration),
            curve: Curves.fastOutSlowIn);
      },
      child: SvgPicture.asset('assets/icon/go-to-top.svg'),
      backgroundColor: Colors.white,
    ),
  );
}