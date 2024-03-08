import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';


class SelectableCard<T> extends StatefulWidget {

  final Widget child;
  final Function()? selectedFunction;
  final Function()? unselectedFunction;
  final bool selected;
  final Duration durationEffect;

  SelectableCard({
    Key? key,
    required this.child,
    this.selectedFunction,
    this.unselectedFunction,
    this.selected = false,
    this.durationEffect = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<SelectableCard<T>> createState() => SelectableCardState<T>();

}

class SelectableCardState<T> extends State<SelectableCard<T>> with TickerProviderStateMixin {

  bool selected = false;

  late DecorationTween decorationTween ;

  late AnimationController _controller;

  @override
  void didUpdateWidget(SelectableCard<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.selected != widget.selected){
      selected = widget.selected;
      if(selected){
        _controller.forward();
      }else{
        _controller.reverse();
      }
      if(mounted)
      setState(() {

      });
    }
  }

  @override
  void initState(){
    selected = widget.selected;
    decorationTween = DecorationTween(
      begin: selected? selectedCardDecoration: cardDecoration,
      end: selected? cardDecoration: selectedCardDecoration,
    );
    _controller = AnimationController(
      vsync: this,
      duration: widget.durationEffect,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context){

    return Container(
      child: DecoratedBoxTransition(
        decoration: decorationTween.animate(_controller),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              onLongPress: (){
                if(selected == false) {
                  widget.selectedFunction?.call();
                  selected = true;
                  _controller.forward();
                }else{
                  widget.unselectedFunction?.call();
                  selected = false;
                  _controller.reverse();
                }
                setState(() {

                });
              },
              child: Stack(
                children: [
                  Container(
                    child: widget.child,
                  ),
                  Positioned(
                    bottom: 5,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.only(left: 13),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          unselectButton(context: context),
                        ],
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }

  Widget unselectButton({required BuildContext context}){
    return AnimatedOpacity(
      duration: widget.durationEffect,
      opacity: selected? 1 : 0,
      child: Visibility(
        visible: selected,
        child: Container(
          padding: const EdgeInsets.all(2),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFEB8B76),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            shadows: [
              const BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 4,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          child: const Icon(Icons.check, size: 20,color: ConstantsV2.lightGrey,),
        ),
      ),
    );
  }

}