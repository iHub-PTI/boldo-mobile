import 'package:boldo/blocs/download_bloc/download_bloc.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:boldo/widgets/selectable/selectableCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectableWidgets<T, LoadingState> extends StatefulWidget {

  final List<SelectableWidgetItem<T>> items;
  final DownloadBloc bloc;
  final DownloadEvent Function(List<String?> listOfIds) downloadEvent;
  final bool enableSelectAll;

  SelectableWidgets({
    Key? key,
    required this.items,
    required this.bloc,
    required this.downloadEvent,
    this.enableSelectAll = true,
  }) : super(key: key);

  @override
  State<SelectableWidgets> createState() => _SelectableWidgetsState<T, LoadingState>();

}


class _SelectableWidgetsState<T, LoadingState> extends State<SelectableWidgets> with TickerProviderStateMixin {

  bool selectAll = false;
  List<String?> listSelectableElements = [];
  late AnimationController _controller;

  Duration durationEffect = const Duration(milliseconds: 100);

  @override
  void initState(){
    _controller = AnimationController(
      vsync: this,
      duration: durationEffect,
    );
    super.initState();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadBloc>(
      create: (BuildContext context) => widget.bloc,
      child: BlocListener<DownloadBloc, DownloadState>(
        listener: (context, state){
          if(state is Failed){
            emitSnackBar(
                context: context,
                text: state.msg,
                status: ActionStatus.Fail
            );
          }
        },
        child: Column(
          children: [
            tabDownload(
              enableAll: widget.enableSelectAll,
            ),
            Expanded(
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) => const Divider(
                  color: Colors.transparent,
                  height: 10,
                ),
                itemCount: widget.items.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index){
                  bool? value = listSelectableElements.contains(widget.items[index].id);
                  return SelectableCard<T>(
                    child: widget.items[index],
                    selected: value?? false,
                    selectedFunction: (){
                      listSelectableElements.add(
                        widget.items[index].id,
                      );
                      checkHeader();
                    },
                    unselectedFunction: (){
                      listSelectableElements.remove(
                        widget.items[index].id,
                      );
                      checkHeader();
                    },
                    durationEffect: durationEffect,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkHeader(){
    //check if someone elements is selected to init animation
    if(listSelectableElements.isNotEmpty){

      //if all elements is selected set selectAll to true
      if(listSelectableElements.length == widget.items.length){
        selectAll = true;
      }else{
        selectAll = false;
      }
      _controller.forward().then((value) => setState(() {

      }));
    }else{
      _controller.reverse().then((value) => setState(() {

      }));
    }
  }

  Widget tabDownload(
      {bool enableAll = true,
  }){
    return AnimatedCrossFade(
      crossFadeState: _controller.isAnimating || _controller.isCompleted? CrossFadeState.showSecond: CrossFadeState.showFirst,
      duration: durationEffect,
      firstChild: Container(),
      secondChild: AnimatedSwitcher(
        switchInCurve: Curves.linear,
        switchOutCurve: Curves.linear,
        duration: durationEffect,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          key: _controller.isAnimating || _controller.isCompleted? Key('header') : null,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.53),
            ),
          ),
          child: _controller.isAnimating || _controller.isCompleted? Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 5,),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (){
                              selectAll =false;
                              listSelectableElements.clear();
                              checkHeader();
                            },
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: ConstantsV2.primaryRegular,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15,),
                        AnimatedSwitcher(
                          duration: durationEffect,
                          child: Text(
                            //use key to detect change on child o animatedSwitcher
                            key: Key("${listSelectableElements.isNotEmpty}"),
                            "${listSelectableElements.length}",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              color: ConstantsV2.blueDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<DownloadBloc, DownloadState>(
                      builder: (BuildContext context, state){
                        if(state is LoadingState){
                          return loadingStatus();
                        }else{
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: (){
                                BlocProvider.of<DownloadBloc>(context).add(
                                  widget.downloadEvent(listSelectableElements),
                                );
                              },
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(
                                      Icons.save_alt_rounded,
                                      color: ConstantsV2.grayDark,
                                    ),
                                    const SizedBox(width: 8,),
                                    Text(
                                      "Descargar",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: enableAll,
                child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Row(
                      children: [
                        Checkbox(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          value: selectAll,
                          activeColor: ConstantsV2.orange,
                          checkColor: Colors.white,
                          onChanged: enableAll? (value) {
                            selectAll = !selectAll;
                            if(selectAll){
                              listSelectableElements = [];
                              listSelectableElements.addAll(widget.items.map((e) => e.id));
                              listSelectableElements = listSelectableElements.toSet().toList();
                            }else{
                              listSelectableElements.clear();
                            }
                            checkHeader();
                          } : null,
                        ),
                        const Flexible(
                          child: Text(
                            chooseAll,
                            style: TextStyle(color: ConstantsV2.activeText),
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ],
          ) : null,
        ),
      ),
    );
  }

}

class SelectableWidgetItem<T> extends StatelessWidget {

  final Widget child;
  final T item;
  final String? id;

  SelectableWidgetItem({
    required this.child,
    required this.item,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

}