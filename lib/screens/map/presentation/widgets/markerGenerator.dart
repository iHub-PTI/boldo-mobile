import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// This just adds overlay and builds [_MarkerHelper] on that overlay.
/// [_MarkerHelper] does all the heavy work of creating and getting bitmaps
class MarkerGenerator {
  final Function(List<Uint8List>) callback;
  final List<Widget> markerWidgets;

  MarkerGenerator(this.markerWidgets, this.callback);

  void generate(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));
  }

  void afterFirstLayout(BuildContext context) {
    addOverlay(context);
  }

  void addOverlay(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);

    OverlayEntry entry = OverlayEntry(
        builder: (context) {
          return _MarkerHelper(
            markerWidgets: markerWidgets,
            callback: callback,
          );
        },
        maintainState: true);


    overlayState.insert(entry);
  }
}

/// Maps are embeding GoogleMap library for Andorid/iOS  into flutter.
///
/// These native libraries accept BitmapDescriptor for marker, which means that for custom markers
/// you need to draw view to bitmap and then send that to BitmapDescriptor.
///
/// Because of that Flutter also cannot accept Widget for marker, but you need draw it to bitmap and
/// that's what this widget does:
///
/// 1) It draws marker widget to tree
/// 2) After painted access the repaint boundary with global key and converts it to uInt8List
/// 3) Returns set of Uint8List (bitmaps) through callback
class _MarkerHelper extends StatefulWidget {
  final List<Widget> markerWidgets;
  final Function(List<Uint8List>) callback;

  const _MarkerHelper({Key? key, required this.markerWidgets, required this.callback})
      : super(key: key);

  @override
  _MarkerHelperState createState() => _MarkerHelperState();


}

class _MarkerHelperState extends State<_MarkerHelper> with AfterLayoutMixin {
  List<GlobalKey> globalKeys = [];

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    List<Uint8List> list = await _getBitmaps(context);
    widget.callback(list);
    // return list;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(MediaQuery.of(context).size.width, 0),
      child: Material(
        child: Stack(
          children: widget.markerWidgets.map((i) {
            final markerKey = GlobalKey();
            globalKeys.add(markerKey);
            return RepaintBoundary(
              key: markerKey,
              child: i,
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<List<Uint8List>> _getBitmaps(BuildContext context) async {
    var futures = globalKeys.map((key) => _getUint8List(key));
    return Future.wait(futures);
  }

  Future<Uint8List> _getUint8List(GlobalKey markerKey) async {
    RenderRepaintBoundary? boundary =
    markerKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List dataImage = data!.buffer.asUint8List();
    return dataImage;
  }
}

/// AfterLayoutMixin
mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then(
          (_) {
        if (mounted) afterFirstLayout(context);
      },
    );
  }

  void afterFirstLayout(BuildContext context);
}