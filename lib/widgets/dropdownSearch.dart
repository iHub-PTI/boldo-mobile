import 'package:boldo/constants.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';

class DropdownSearch<T> extends StatefulWidget {

  final Widget Function(BuildContext, String)? emptyBuilder;
  final void Function(T?)? onSelectItem;
  final void Function(T?)? onRemoveElement;
  final Future<List<T>>? Function(String name)? listObjects;
  final String Function(T? data) toStringItem;
  final T? selected;

  DropdownSearch({
    super.key,
    this.emptyBuilder,
    this.onSelectItem,
    this.onRemoveElement,
    this.listObjects,
    required this.toStringItem,
    this.selected,
  });

  @override
  _DropdownSearchState createState() => _DropdownSearchState<T>();
}

class _DropdownSearchState<T> extends State<DropdownSearch<T>> {
  TextEditingController _textEditingController = TextEditingController();
  OverlayEntry? overlayEntry;

  T? selected;

  Rect? _popUpRegion;

  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  @override
  void dispose(){
    if(overlayEntry?.mounted?? false) {
      overlayEntry?.remove();
      overlayEntry?.dispose();
    }
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DropdownSearch<T> oldWidget){

    setState(() {

    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: widget.selected == null ? TextField(
                controller: _textEditingController,
                onTapOutside: (PointerDownEvent point){


                  double left = _popUpRegion?.left?? 0;
                  double top = _popUpRegion?.top?? 0;
                  double bottom = _popUpRegion?.bottom?? 0;
                  double right = _popUpRegion?.right?? 0;

                  // unfocus on tap outside of popUpRegion
                  if(point.position.dx < left || point.position.dx > right
                      ||
                      point.position.dy < top || point.position.dy > bottom
                  ){
                    if(overlayEntry?.mounted?? false) {
                      overlayEntry?.remove();
                      overlayEntry?.dispose();
                      overlayEntry = null;
                    }{
                      FocusScope.of(context).unfocus();
                    }
                  }
                },
                onChanged: (value) {
                  setState(() {

                    if(overlayEntry?.mounted?? false) {
                      overlayEntry?.remove();
                      overlayEntry?.dispose();
                      overlayEntry = null;
                    }

                    if(value.isNotEmpty){
                      if(! (overlayEntry?.mounted?? false)) {

                        overlayEntry = OverlayEntry(
                          builder: (context) => popUpItems(
                            emptyBuilder: widget.emptyBuilder,
                          ),
                        );

                        Overlay.of(context).insert(overlayEntry!);

                      }
                    }else{
                      _popUpRegion = null;
                    }
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Ingrese nombre del médico',
                ),
              ) : Directionality(
                textDirection: TextDirection.rtl,
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: Theme.of(context).inputDecorationTheme.enabledBorder,
                  ),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(16)
                              ),
                              side: BorderSide(
                                width: 0.5,
                                color: ConstantsV2.gray,
                              ),
                            ),
                          ),
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: ConstantsV2.activeText,
                              textStyle: boldoBodyLRegularTextStyle,
                              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
                            ),
                            onPressed: (){
                              widget.onRemoveElement?.call(selected);
                              selected = null;
                              _textEditingController.text = '';
                              setState(() {

                              });
                            },
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: ConstantsV2.gray,
                              size: 18,
                            ),
                            label: Text(widget.toStringItem(selected)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // overlayEntryOutside!.builder(context),
      ],
    );
  }

  RelativeRect _position(RenderBox popupButtonObject, RenderBox overlay) {
    // Calculate the show-up area for the dropdown using button's size & position based on the `overlay` used as the coordinate space.
    return RelativeRect.fromSize(
      Rect.fromPoints(
        popupButtonObject.localToGlobal(popupButtonObject.size.bottomLeft(Offset.zero), ancestor: overlay),
        popupButtonObject.localToGlobal(popupButtonObject.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Size(overlay.size.width, overlay.size.height),
    );
  }

  Widget popUpItems({Widget Function(BuildContext, String)? emptyBuilder}){

    // Here we get the render object of our physical button, later to get its size & position
    final popupButtonObject = context.findRenderObject() as RenderBox;
    // Get the render object of the overlay use
    var overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = _position(popupButtonObject, overlay);

    final viewInsets = EdgeInsets.fromViewPadding(View.of(context).viewInsets,View.of(context).devicePixelRatio);

    final keyboardHeight = viewInsets.bottom + kMiniButtonOffsetAdjustment;

    // set popUp region
    _popUpRegion = Rect.fromPoints(
      Offset(position.left, position.top),
      Offset(overlay.size.width - position.right, overlay.size.height - keyboardHeight),
    );

    Widget _popUp = Positioned(
      top: position.top,
      left: position.left,
      right: position.right,
      child: Container(
        constraints: BoxConstraints(maxHeight: (overlay.size.height - keyboardHeight) - position.top ),
        child: Material(
          elevation: 2.0,
          child: FutureBuilder<List<T>>(
            future: widget.listObjects!.call(_textEditingController.text),
            builder: (context, AsyncSnapshot<List<T>> result){

              if (result.connectionState == ConnectionState.done) {
                return SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: result.data?.isNotEmpty?? false ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: result.data
                        !.asMap().entries.map((item){
                          return ListTile(
                            title: Text(widget.toStringItem(item.value)),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              _textEditingController.text = widget.toStringItem(item.value);
                              if(overlayEntry?.mounted?? false) {
                                overlayEntry?.remove();
                                overlayEntry?.dispose();
                                _popUpRegion = null;
                              }

                              if(widget.onSelectItem != null) {
                                widget.onSelectItem!(item.value);
                                setState(() {
                                  selected = item.value;
                                });
                              }

                            },
                          );
                    }).toList()
                  ) : emptyBuilder?.call(context, _textEditingController.text)?? Container(),
                );
              }else {
                return loadingStatus();
              }
            },
          ),
        ),
      ),
    );

    return _popUp;
  }

}