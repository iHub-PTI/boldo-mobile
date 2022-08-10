import 'package:boldo/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// this class show my passport tab
class PassportTab extends StatefulWidget {
  // class constructor
  PassportTab({Key? key}) : super(key: key);

  // initial state for this Stateful
  @override
  _PassportTabState createState() => _PassportTabState();
}

// this class define the passport state
class _PassportTabState extends State<PassportTab> {
  // principal view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: MediaQuery.of(context).size.width,
        child: Column(
          // starts at the top of the page
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // button and label for go to back
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  size: 25,
                  color: Constants.extraColor400,
                ),
                label: Text(
                  'Pasaporte',
                  style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
