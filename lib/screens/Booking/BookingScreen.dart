import 'package:boldo/widgets/calendar/Calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constant.dart';

class BookingScreen extends StatefulWidget {
  BookingScreen({Key key}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: SvgPicture.asset('assets/Logo.svg',
                semanticsLabel: 'BOLDO Logo'),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 18,
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.chevron_left_rounded,
                  size: 25,
                  color: boldoTitleTextColor,
                ),
                label: Text(
                  'Reservar',
                  style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                ),
              ),
              SizedBox(
                height: 18,
              ),
              _BookDoctorCard(),
              SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: _BookCalendar(),
              )
            ],
          ),
        ));
  }
}

class _BookCalendar extends StatelessWidget {
  const _BookCalendar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Más fechas',
          style: boldoHeadingTextStyle,
        ),
        SizedBox(
          height: 18,
        ),
        CustomCalendar(
          selectedDate: DateTime.now(),
        ),
        SizedBox(
          height: 25,
        ),
        Center(
          child: Text(
            "14 de septiembre del 2020",
            style: boldoHeadingTextStyle.copyWith(
                fontWeight: FontWeight.normal, fontSize: 14),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 350,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 13,
              runSpacing: 10,
              children: [
                ...[
                  "08:00",
                  "08:20",
                  "08:40",
                  "08:40",
                  "09:20",
                  "09:40",
                  "10:40",
                  "11:00",
                  "11:20",
                  "13:20",
                  "14:40",
                  '15:00'
                ]
                    .map((e) => Card(
                          child: Container(
                            width: 60,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                e,
                                textAlign: TextAlign.center,
                                style: boldoHeadingTextStyle.copyWith(
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        ))
                    .toList()
              ],
            ),
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 16),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: boldoDarkPrimaryLighterColor,
            ),
            onPressed: () {
              //
            },
            child: Text("Aceptar"),
          ),
        )
      ],
    );
  }
}

class _BookDoctorCard extends StatelessWidget {
  const _BookDoctorCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 96,
            padding: EdgeInsets.only(top: 18, right: 19, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: SvgPicture.asset('assets/icon/clockIcon.svg',
                        semanticsLabel: 'Clock Icon'),
                  ),
                ),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Disponible Hoy!",
                          style: boldoHeadingTextStyle.copyWith(fontSize: 14),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Lunes 7 de septiembre",
                          style: boldoSubTextStyle,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "14:30 horas",
                          style: boldoSubTextStyle,
                        ),
                      ],
                    ),
                    flex: 5),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: boldoBackgroundLightColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: TextButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => DoctorProfileScreen(),
                //   ),
                // );
              },
              child: Text(
                'Reservar ahora',
                style: boldoHeadingTextStyle.copyWith(
                    color: boldoDarkPrimaryLighterColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
