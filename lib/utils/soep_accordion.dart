import 'package:boldo/models/Soep.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class SoepAccordion extends StatefulWidget {
  final String title;
  final List<Soep> soep;

  SoepAccordion(this.title, this.soep);
  @override
  _SoepAccordionState createState() => _SoepAccordionState();
}

class _SoepAccordionState extends State<SoepAccordion> {
  bool _showContent = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Constants.accordionbg,
      margin: const EdgeInsets.only(top: 5),
elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white70, width: 5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        ListTile(
          title: Text(
            widget.title,
            style: boldoHeadingTextStyle.copyWith(
                fontSize: 18, color: Constants.primaryColor500),
          ),
          trailing: IconButton(
            icon: Icon(
              _showContent ? Icons.expand_less : Icons.expand_more,
              color: Constants.primaryColor500,
            ),
            onPressed: () {
              setState(() {
                _showContent = !_showContent;
              });
            },
          ),
        ),
        _showContent
            ? Container(
                height: 250,
                // width:300,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: SoepList(widget.soep),
              )
            : Container()
      ]),
    );
  }
}

class SoepList extends StatelessWidget {
  final List<Soep> soep;
  SoepList(this.soep);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: soep.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: Container(
            // height: 300,
            width: 300,

            child: Card(
              color: Constants.accordionbg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(soep[index].title,
                        style: boldoHeadingTextStyle.copyWith(
                            fontSize: 14, color: Constants.secondaryColor500)),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(soep[index].date,
                          style: boldoHeadingTextStyle.copyWith(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        soep[index].description,
                        style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15),
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
}
