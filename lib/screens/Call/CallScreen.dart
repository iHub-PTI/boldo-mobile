import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';

import '../../utils/signaling.dart';
import '../../constants.dart';
import '../../size_config.dart';

import './components/speed_dial.dart';
import './components/waiting_room_popup.dart';
import './components/connection_problem_popup.dart';
import './components/call_ended_popup.dart';

import '../Dashboard/DashboardScreen.dart';

class CallScreen extends StatefulWidget {
  CallScreen({Key key, @required this.appointmentId}) : super(key: key);
  final String appointmentId;
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  GlobalKey _key = GlobalKey();

  Signaling _signaling;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _showingConnectionProblemPopup = true;

  double xCameraPos = 16.0;
  double yCameraPos = 340.0;

  @override
  void initState() {
    super.initState();
    yCameraPos = SizeConfig.safeBlockVertical * 64;

    initRenderers();
    _connect();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    bool popupResonse = await waitingRoomModal(
        context: context,
        localRenderer: _localRenderer,
        handleBackButton: _handleBackButton);

    if (popupResonse) {
      Navigator.of(context).pop();
    }
  }

  @override
  void deactivate() {
    super.deactivate();

    if (_signaling != null) _signaling.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void _connect() async {
    if (_signaling == null) {
      _signaling = Signaling(widget.appointmentId)..connect();

      _signaling.onStateChange = (SignalingState state) async {
        switch (state) {
          case SignalingState.CallStateNew:
            setState(() {
              _inCalling = true;
            });
            //close waiting room popup
            Navigator.of(context).pop();
            break;
          case SignalingState.CallStateBye:
            setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              _inCalling = false;
            });
            break;
          case SignalingState.CallStateInvite:
          case SignalingState.CallStateConnected:

          case SignalingState.CallStateRinging:
          case SignalingState.ConnectionClosed:
            break;
          case SignalingState.ConnectionError:
            if (_showingConnectionProblemPopup) return;
            setState(() {
              _showingConnectionProblemPopup = true;
            });
            await connectionProblemPopup(
                context: context, leaveScreenCallback: _hangUp);
            break;
          case SignalingState.ConnectionOpen:
            break;
          case SignalingState.ConnectionEndedByDoctor:
            setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              _inCalling = false;
            });

            await callEndedPopup(
              context: context,
            );
            break;
        }
      };
      _signaling.onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
      });
      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
      });
    }
  }

  void _cleanUp() {
    if (_signaling != null) {
      _signaling.bye(doctorDisconnect: false);
    }
  }

  void _hangUp() async {
    _signaling.emitEndCallEvent();
    _cleanUp();
    await callEndedPopup(
      context: context,
    );
  }

  void _switchCamera() {
    print("switch camera");
    _signaling.switchCamera();
  }

  Future<bool> _handleBackButton() async {
    bool popupResonse = await yesOrNoDialog(
        context: context, text: "Are you sure you want to exit the call?");

    if (popupResonse != null && popupResonse) {
      if (_inCalling) {
        //emit end call event
        _hangUp();
      } else {
        //emit peer not ready event
        _signaling.leaveWaitingRoom();
        _cleanUp();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(),
          ),
        );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _handleBackButton();
      },
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            titleSpacing: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white,
                    Color.fromRGBO(255, 255, 255, 0)
                  ],
                ),
              ),
            ),
            toolbarHeight: 80,
            title: const Text(
              "Dra. Susan Giménez",
              style: TextStyle(color: Constants.extraColor400),
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () async {
                bool popupResponse = await _handleBackButton();
                if (popupResponse) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _inCalling
              ? Padding(
                  padding:
                      const EdgeInsets.only(bottom: 20, left: 24, right: 24),
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
                          onPressed: _hangUp,
                          tooltip: 'Hangup',
                          elevation: 0,
                          child: SvgPicture.asset(
                            'assets/icon/hangup.svg',
                            semanticsLabel: 'Hang Up Icon',
                            color: Colors.white,
                          ),
                          backgroundColor: const Color(0xffF56565),
                        ),
                        SpeedDial(switchCameraCallback: _switchCamera)
                      ]),
                )
              : null,
          body: _inCalling
              ? OrientationBuilder(
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
                            _remoteRenderer,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          ),
                        ),
                        Positioned(
                          key: _key,
                          left: xCameraPos,
                          top: yCameraPos,
                          child: Draggable(
                            feedback: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                              child: Container(
                                width: orientation == Orientation.portrait
                                    ? 120
                                    : 160,
                                height: orientation == Orientation.portrait
                                    ? 160
                                    : 120,
                                child: RTCVideoView(_localRenderer),
                              ),
                            ),
                            childWhenDragging: Container(),
                            onDragEnd: (drag) {
                              double valY = drag.offset.dy;
                              double valX = drag.offset.dx;
                              if (drag.offset.dy <
                                  SizeConfig.safeBlockVertical * 14) {
                                valY = SizeConfig.safeBlockVertical * 14;
                              } else if (drag.offset.dy >
                                  SizeConfig.safeBlockVertical * 66) {
                                valY = SizeConfig.safeBlockVertical * 66;
                              }
                              if (drag.offset.dx <
                                  SizeConfig.safeBlockHorizontal * 4) {
                                valX = SizeConfig.safeBlockHorizontal * 4;
                              } else if (drag.offset.dx >
                                  SizeConfig.safeBlockHorizontal * 65) {
                                valX = SizeConfig.safeBlockHorizontal * 65;
                              }

                              setState(() {
                                yCameraPos = valY;

                                xCameraPos = valX;
                              });
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                              child: Container(
                                width: orientation == Orientation.portrait
                                    ? 120
                                    : 160,
                                height: orientation == Orientation.portrait
                                    ? 160
                                    : 120,
                                child: RTCVideoView(_localRenderer),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    );
                  },
                )
              : const SizedBox()),
    );
  }
}

Future<bool> yesOrNoDialog(
    {BuildContext context,
    String text,
    String yesButton = "YЕS",
    String noButton = "NO",
    bool positive = false}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              noButton,
              style: TextStyle(color: positive ? Colors.grey : Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text(
              yesButton,
              style: TextStyle(color: positive ? Colors.green : Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}
