import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';

import '../constants.dart';

class ImageVisor extends StatelessWidget {
  final String url;

  ImageVisor({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: SvgPicture.asset('assets/Logo.svg',
            width: 100, semanticsLabel: 'BOLDO Logo'),
      ),
      body: ImageVisorScreen(url: url),
    );
  }
}

class ImageVisorScreen extends StatefulWidget {
  final String url;

  ImageVisorScreen({Key? key, required this.url}) : super(key: key);

  @override
  State createState() => ImageVisorScreenState(url: url);
}

class ImageVisorScreenState extends State<ImageVisorScreen> {
  final String url;

  ImageVisorScreenState({Key? key, required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
      imageProvider: CachedNetworkImageProvider(url),
    ));
  }
}
