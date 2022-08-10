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
  // function for show qr alert
  void showQrOptionsDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext cxt) {
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
              ? const EdgeInsets.all(10)
              : const EdgeInsets.all(16),
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
                  ? const EdgeInsets.all(10)
                  : const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        //Navigator.pushNamed(context, '/user_qr_detail');
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white70, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SvgPicture.asset('assets/icon/select_all.svg'),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        //Navigator.pushNamed(context, '/vaccine_filter');
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white70, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            SvgPicture.asset('assets/icon/select_to_show.svg'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
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
            ),
            // label and options for download vaccination
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 16,top: 10),
              child: Row(
                children: [
                  // Inmunizaciones label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Inmunizaciones',
                            style: boldoHeadingTextStyle.copyWith(
                              fontSize: 20
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // get QR whit an alert
                  GestureDetector(
                    onTap: () => showQrOptionsDialog(context),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SvgPicture.asset(
                          'assets/icon/qrcode.svg',
                          color: Colors.grey[800],
                          height: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // pdf download
                  GestureDetector(
                    // add bloc code
                    onTap: () {

                    },
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SvgPicture.asset(
                          'assets/icon/document-text.svg',
                          color: Colors.grey[800],
                          height: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
