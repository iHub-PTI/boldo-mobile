import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:boldo/models/Appointment.dart';
import 'package:boldo/constants.dart';
import 'package:boldo/screens/Call/components/speed_dial.dart';
import 'package:boldo/size_config.dart';
import '../../../utils/helpers.dart';

class Call extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final Function hangUp;
  final Function switchCamera;
  final Appointment appointment;

  const Call({
    Key key,
    @required this.localRenderer,
    @required this.remoteRenderer,
    @required this.hangUp,
    @required this.switchCamera,
    @required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 32,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Colors.white,
                Color.fromRGBO(255, 255, 255, 0.65),
                Color.fromRGBO(255, 255, 255, 0)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(
            "${getDoctorPrefix(appointment.doctor.gender)} ${appointment.doctor.familyName}",
            style: const TextStyle(color: Constants.grayColor800),
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Opacity(
                opacity: 0,
                child: FloatingActionButton(
                  heroTag: null,
                  onPressed: null,
                ),
              ),
              FloatingActionButton(
                heroTag: null,
                onPressed: hangUp,
                tooltip: 'Hangup',
                elevation: 0,
                child: SvgPicture.asset(
                  'assets/icon/hangup.svg',
                  semanticsLabel: 'Hang Up Icon',
                  color: Colors.white,
                ),
                backgroundColor: const Color(0xffF56565),
              ),
              SpeedDial(switchCameraCallback: switchCamera)
            ]),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Container(
            color: Colors.white,
            child: Stack(fit: StackFit.expand, children: <Widget>[
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 0.0,
                bottom: 0.0,
                child: RTCVideoView(
                  remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
              CustomPositionedCamera(
                  localRenderer: localRenderer, orientation: orientation),
            ]),
          );
        },
      ),
    );
  }
}

class CustomPositionedCamera extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final Orientation orientation;

  const CustomPositionedCamera({
    Key key,
    @required this.localRenderer,
    @required this.orientation,
  }) : super(key: key);

  @override
  _CustomPositionedCameraState createState() => _CustomPositionedCameraState();
}

class _CustomPositionedCameraState extends State<CustomPositionedCamera> {
  double xCameraPos = 16.0;
  double yCameraPos = 340.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: xCameraPos,
      top: yCameraPos,
      child: Draggable(
        feedback: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            width: widget.orientation == Orientation.portrait ? 120 : 160,
            height: widget.orientation == Orientation.portrait ? 160 : 120,
            child: RTCVideoView(widget.localRenderer),
          ),
        ),
        childWhenDragging: Container(),
        onDragEnd: (drag) {
          double valY = drag.offset.dy;
          double valX = drag.offset.dx;

          if (drag.offset.dy < SizeConfig.safeBlockVertical * 14) {
            valY = SizeConfig.safeBlockVertical * 14;
          } else if (drag.offset.dy > SizeConfig.safeBlockVertical * 66) {
            valY = SizeConfig.safeBlockVertical * 66;
          }
          if (drag.offset.dx < SizeConfig.safeBlockHorizontal * 4) {
            valX = SizeConfig.safeBlockHorizontal * 4;
          } else if (drag.offset.dx > SizeConfig.safeBlockHorizontal * 65) {
            valX = SizeConfig.safeBlockHorizontal * 65;
          }

          setState(() {
            yCameraPos = valY;
            xCameraPos = valX;
          });
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            width: widget.orientation == Orientation.portrait ? 120 : 160,
            height: widget.orientation == Orientation.portrait ? 160 : 120,
            child: RTCVideoView(widget.localRenderer),
          ),
        ),
      ),
    );
  }
}
