import 'package:boldo/models/Doctor.dart';
import 'package:boldo/widgets/custom_form_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../network/http.dart';
import '../../widgets/wrapper.dart';
import '../../constants.dart';
import '../../utils/helpers.dart';
import 'booking_final_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  final Doctor doctor;
  final DateTime bookingDate;
  BookingConfirmScreen(
      {Key key, @required this.bookingDate, @required this.doctor})
      : super(key: key);

  @override
  _BookingConfirmScreenState createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  bool _loading = false;
  String _error = "";
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
        _DoctorProfileWidget(doctor: widget.doctor),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: _DoctorBookingInfoWidget(
            bookingDate: widget.bookingDate,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Center(
          child: Text(
            _error,
            style: const TextStyle(
              fontSize: 14,
              color: Constants.otherColor100,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: CustomFormButton(
            text: "Confirmar",
            loading: _loading,
            actionCallback: () async {
              try {
                setState(() {
                  _loading = true;
                  _error = "";
                });

                await dio
                    .post("/profile/patient/appointments", queryParameters: {
                  'start': widget.bookingDate.toIso8601String(),
                  "doctorId": widget.doctor.id,
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingFinalScreen()),
                );
              } on DioError catch (err) {
                print(err);
                setState(() {
                  _loading = false;
                  _error = "Somethig went wrong, please try again later.";
                });
              } catch (err) {
                print(err);
                setState(() {
                  _loading = false;
                  _error = "Somethig went wrong, please try again later.";
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

class _DoctorBookingInfoWidget extends StatelessWidget {
  final DateTime bookingDate;
  const _DoctorBookingInfoWidget({Key key, @required this.bookingDate})
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
          DateFormat('EEEE, dd MMMM yyyy').format(bookingDate).capitalize(),
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
          "${DateFormat('HH:mm').format(bookingDate)} horas",
          style: boldoSubTextStyle.copyWith(fontSize: 16),
        ),
      ],
    );
  }
}

class _DoctorProfileWidget extends StatelessWidget {
  final Doctor doctor;
  const _DoctorProfileWidget({Key key, @required this.doctor})
      : super(key: key);

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 72,
                        width: 72,
                        child: doctor.photoUrl == null
                            ? SvgPicture.asset(
                                doctor.gender == "female"
                                    ? 'assets/images/femaleDoctor.svg'
                                    : 'assets/images/maleDoctor.svg',
                                fit: BoxFit.cover)
                            : CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: doctor.photoUrl,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Padding(
                                  padding: const EdgeInsets.all(26.0),
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${getDoctorPrefix(doctor.gender)} ${doctor.givenName} ${doctor.familyName}",
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
                if (doctor.biography != null)
                  Text(doctor.biography,
                      style: boldoSubTextStyle.copyWith(
                          fontSize: 16, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
