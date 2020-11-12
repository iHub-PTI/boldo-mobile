import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/wrapper.dart';
import '../../constants.dart';
import 'booking_final_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  final String bookingHour;
  final DateTime bookingDate;
  BookingConfirmScreen(
      {Key key, @required this.bookingHour, @required this.bookingDate})
      : super(key: key);

  @override
  _BookingConfirmScreenState createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      children: [
        const SizedBox(
          height: 20,
        ),
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
            'Reservar',
            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const _DoctorProfileWidget(),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: _DoctorBookingInfoWidget(
            bookingHour: widget.bookingHour,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          margin: const EdgeInsets.only(bottom: 16),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Constants.primaryColor500,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingFinalScreen()),
              );
            },
            child: const Text("Confirmar"),
          ),
        )
      ],
    );
  }
}

class _DoctorBookingInfoWidget extends StatelessWidget {
  final String bookingHour;
  const _DoctorBookingInfoWidget({Key key, @required this.bookingHour})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fecha",
          style: boldoHeadingTextStyle,
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          "Lunes 7 de septiembre del 2020",
          style: boldoSubTextStyle.copyWith(fontSize: 16),
        ),
        const SizedBox(
          height: 24,
        ),
        const Text(
          "Hora",
          style: boldoHeadingTextStyle,
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          "$bookingHour horas",
          style: boldoSubTextStyle.copyWith(fontSize: 16),
        ),
      ],
    );
  }
}

class _DoctorProfileWidget extends StatelessWidget {
  const _DoctorProfileWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 24, right: 19, bottom: 24, left: 19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/ProfileImage.svg',
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dra. Susan Giménez",
                          style: boldoHeadingTextStyle.copyWith(
                              fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Dermatología",
                          style: boldoSubTextStyle.copyWith(
                              color: Constants.otherColor100),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                    "Recibida en la Universidad Nacional de Asunción en Dermatología. Especialización en Dermatología Estética. Miembro de la Asociación LADERM. ",
                    style:
                        boldoSubTextStyle.copyWith(fontSize: 16, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
