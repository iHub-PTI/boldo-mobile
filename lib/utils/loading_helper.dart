import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../constants.dart';
import '../main.dart';

class LoadingHelper extends StatefulWidget {
  final File? image;
  final QrImage? qrImage;
  const LoadingHelper({Key? key, this.image, this.qrImage}) : super(key: key);

  @override
  State<LoadingHelper> createState() => _LoadingHelperState();
}

class _LoadingHelperState extends State<LoadingHelper> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          userImageSelected != null
              ? Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Opacity(
                opacity: 0.5,
                child: Image.file(
                  File(userImageSelected!.path),
                ),
              ),
            ),
          )
              : widget.qrImage != null
              ? Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Opacity(
                opacity: 0.5,
                child: widget.qrImage,
              ),
            ),
          ) : Container(
            width:  MediaQuery.of(context).size.width,
            height:  MediaQuery.of(context).size.height,
            color: Colors.white.withOpacity(0.1),
          ),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/loading.gif',
              height: 60,
              width: 60,
            ),
          ),
        ],
      ),
    );
  }
}

class SuccesLoaded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color:  Constants.primaryColor600,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icon/success.svg',
            ),
          )
        ],
      ),
    );
  }
}