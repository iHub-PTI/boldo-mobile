import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../widgets/wrapper.dart';

import '../../constants.dart';

class Contact extends StatefulWidget {
  const Contact({Key? key}) : super(key: key);

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget labelLink() {
    return const Text('soporte.boldo@pti.org.py',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Color.fromRGBO(237, 152, 62, 1),
            fontFamily: 'Inter',
            fontSize: 20,
            letterSpacing: 0.15000000596046448,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.underline,
            height: 1.2));
  }

  @override
  Widget build(BuildContext context) {
    return CustomWrapper(children: [
      const SizedBox(height: 24),
      TextButton.icon(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.chevron_left_rounded,
          size: 25,
          color: Constants.extraColor400,
        ),
        label: Text(
          'Centro de Ayuda',
          style: boldoHeadingTextStyle.copyWith(fontSize: 20),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          text: const TextSpan(
            text: '\nPara obtener ayuda, escribanos a​\n',
            style: TextStyle(
                color: Color.fromRGBO(54, 65, 82, 1),
                fontFamily: 'PT Serif',
                fontSize: 20,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
                height: 1.5 /*PERCENT not supported*/
                ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Center(
          child: GestureDetector(
              onTap: () {
                _launchInBrowser("https://www.pti.org.py/");
              },
              child: labelLink()),
        ),
      )
    ]);
  }
}
