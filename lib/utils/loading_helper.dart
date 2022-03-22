import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';

class LoadingHelper extends StatefulWidget {
  final File? image;
  const LoadingHelper({Key? key, this.image}) : super(key: key);

  @override
  State<LoadingHelper> createState() => _LoadingHelperState();
}

class _LoadingHelperState extends State<LoadingHelper> {
  bool _loaded = false;
  Future<void> timer() async {
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      _loaded = true;
    });
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);
  }

  @override
  void initState() {
    timer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: !_loaded ? Colors.transparent : Constants.primaryColor600,
        child: Stack(
          children: [
            widget.image != null && !_loaded
                ? Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Opacity(
                  opacity: 0.5,
                  child: Image.file(
                    widget.image!,
                  ),
                ),
              ),
            )
                : Container(),
            Align(
              alignment: Alignment.center,
              child: !_loaded
                  ? Image.asset(
                'assets/images/loading.gif',
              )
                  : SvgPicture.asset(
                'assets/icon/success.svg',
              ),
            )
          ],
        )
      )
    );
  }
}