import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../utils/signaling.dart';

class CallScreen extends StatefulWidget {
  CallScreen({Key key, @required this.appointmentId}) : super(key: key);
  final String appointmentId;
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Signaling _signaling;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;

  @override
  void initState() {
    super.initState();
    initRenderers();
    _connect();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
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
            Navigator.pop(context);
            break;
          case SignalingState.ConnectionOpen:
            break;
          case SignalingState.ConnectionEndedByDoctor:
            setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              _inCalling = false;
            });
            await infoDialog(
                context: context, text: "The doctor has left the call");
            Navigator.pop(context);
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

  void _hangUp() {
    _signaling.emitEndCallEvent();
    _cleanUp();
    Navigator.of(context).pop();
  }

  void _switchCamera() {
    _signaling.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //ask if the user is sure he wants to leave the call

        bool popupResonse = await yesOrNoDialog(
            context: context, text: "Are you sure you want to exit the call?");

        if (popupResonse) {
          if (_inCalling) {
            //emit end call event
            _hangUp();
          } else {
            //emit peer not ready event
            _signaling.leaveWaitingRoom();
            _cleanUp();
          }
        }

        return popupResonse;
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        floatingActionButton: _inCalling
            ? Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: "btn1",
                        child: const Icon(Icons.arrow_back),
                        onPressed: _hangUp,
                      ),
                      FloatingActionButton(
                        heroTag: "btn2",
                        child: const Icon(Icons.switch_camera),
                        onPressed: _switchCamera,
                      ),
                      FloatingActionButton(
                        heroTag: "btn3",
                        onPressed: _hangUp,
                        tooltip: 'Hangup',
                        child: const Icon(Icons.call_end),
                        backgroundColor: Colors.pink,
                      ),
                    ]),
              )
            : null,
        body: _inCalling
            ? OrientationBuilder(builder: (context, orientation) {
                return Container(
                  child: Stack(children: <Widget>[
                    Positioned(
                        left: 0.0,
                        right: 0.0,
                        top: 0.0,
                        bottom: 0.0,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: RTCVideoView(_remoteRenderer),
                          decoration:
                              const BoxDecoration(color: Colors.black54),
                        )),
                    Positioned(
                      left: 20.0,
                      bottom: 20.0,
                      child: Container(
                        width:
                            orientation == Orientation.portrait ? 90.0 : 120.0,
                        height:
                            orientation == Orientation.portrait ? 120.0 : 90.0,
                        child: RTCVideoView(_localRenderer),
                        decoration: const BoxDecoration(color: Colors.black54),
                      ),
                    ),
                  ]),
                );
              })
            : Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Waiting Room",
                        style: TextStyle(
                            color: Colors.grey[850],
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Waiting for the doctor to connect...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400,
                            fontSize: 17),
                      ),
                    ],
                  ),
                ),
              ),
      ),
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

Future infoDialog(
    {BuildContext context,
    String text,
    String yesButton = "OK",
    bool positive = false}) async {
  return showDialog(
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
