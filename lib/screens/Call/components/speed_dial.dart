import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

class SpeedDial extends StatefulWidget {
  final switchCameraCallback;
  SpeedDial({Key key, this.switchCameraCallback}) : super(key: key);
  @override
  State createState() => SpeedDialState();
}

class SpeedDialState extends State<SpeedDial> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve:
                  const Interval(0.0, 1.0 - 0 / 3 / 2.0, curve: Curves.easeOut),
            ),
            child: FloatingActionButton(
              elevation: 0,
              heroTag: null,
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
              child: SvgPicture.asset(
                'assets/icon/mic.svg',
                semanticsLabel: 'Mic Icon',
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve:
                  const Interval(0.0, 1.0 - 1 / 3 / 2.0, curve: Curves.easeOut),
            ),
            child: FloatingActionButton(
              heroTag: null,
              elevation: 0,
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
              child: SvgPicture.asset(
                'assets/icon/videocam.svg',
                semanticsLabel: 'Camera Icon',
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve:
                  const Interval(0.0, 1.0 - 2 / 3 / 2.0, curve: Curves.easeOut),
            ),
            child: FloatingActionButton(
                heroTag: null,
                elevation: 0,
                backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                child: SvgPicture.asset(
                  'assets/icon/refresh.svg',
                  semanticsLabel: 'Swap Icon',
                  color: Colors.white,
                ),
                onPressed: widget.switchCameraCallback),
          ),
        )
      ]..add(
          FloatingActionButton(
            elevation: 0,
            heroTag: null,
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                return Transform(
                  transform:
                      Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: SvgPicture.asset(
                    'assets/icon/dotsvertical.svg',
                    semanticsLabel: 'Vertical Dots Icon',
                    color: Colors.white,
                  ),
                );
              },
            ),
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
          ),
        ),
    );
  }
}
