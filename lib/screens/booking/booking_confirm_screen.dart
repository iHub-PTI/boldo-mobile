import 'package:boldo/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import 'package:boldo/models/Doctor.dart';
import 'package:boldo/widgets/custom_form_button.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../network/http.dart';
import '../../widgets/wrapper.dart';
import '../../constants.dart';
import '../../utils/helpers.dart';
import 'booking_final_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  final Doctor doctor;
  final NextAvailability bookingDate;
  BookingConfirmScreen(
      {Key? key, required this.bookingDate, required this.doctor})
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
            'Agendar',
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
            bookingDate: DateTime.parse(widget.bookingDate.availability!),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ShowAppoinmentDescription(
          nextAvailability: widget.bookingDate,
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
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          margin: const EdgeInsets.only(bottom: 16),
          child: CustomFormButton(
            text: "Confirmar",
            loading: _loading,
            actionCallback: () async {
              Response response;
              try {
                setState(() {
                  _loading = true;
                  _error = "";
                });
                print("start: ${DateTime.parse(widget.bookingDate.availability!)
                    .toLocal()
                    .toIso8601String()}");
                print("start: ${widget.doctor.id}");
                print("start: ${widget.bookingDate.appointmentType}");
                if(! prefs.getBool("isFamily")!)
                  response = await dio.post("/profile/patient/appointments", data: {
                    'start': DateTime.parse(widget.bookingDate.availability!)
                        .toUtc()
                        .toIso8601String(),
                    "doctorId": widget.doctor.id,
                    "appointmentType":widget.bookingDate.appointmentType
                  });
                else
                  response = await dio.post("/profile/caretaker/dependent/${patient.id}/appointments", data: {
                    'start': DateTime.parse(widget.bookingDate.availability!)
                        .toUtc()
                        .toIso8601String(),
                    "doctorId": widget.doctor.id,
                    "appointmentType":widget.bookingDate.appointmentType
                  });
                if(response.statusCode == 200) {
                  setState(() {
                    _loading = false;
                    _error = "";
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingFinalScreen()),
                  );
                }else {
                  setState(() {
                    _loading = false;
                    _error = response.data['message'];
                  });
                }

              } on DioError catch (exception, stackTrace) {
                print(exception.response?.data['message']);
                setState(() {
                  _loading = false;
                  _error = exception.response?.data['message'];
                });
                await Sentry.captureException(
                  exception,
                  stackTrace: stackTrace,
                );
              } catch (exception, stackTrace) {
                print(exception);
                setState(() {
                  _loading = false;
                  _error = "Intente nuevamente, por favor";
                });
                await Sentry.captureException(
                  exception,
                  stackTrace: stackTrace,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class ShowAppoinmentDescription extends StatelessWidget {
  final NextAvailability nextAvailability;
  const ShowAppoinmentDescription({Key? key, required this.nextAvailability})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inPersonDesc =
        "Esta consulta será realizada en persona en el Hospital Los Ángeles.";
    final onlineDesc =
        "Esta consulta será realizada de forma remota a través de esta aplicación.";
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: Constants.accordionbg),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: ShowAppoinmentTypeIcon(appointmentType: nextAvailability.appointmentType!),
                title: Text(
                  nextAvailability.appointmentType == 'A'
                      ? inPersonDesc
                      : onlineDesc,
                  style: boldoSubTextStyle.copyWith(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          )),
    );
  }
}

class ShowAppoinmentTypeIcon extends StatelessWidget {
  const ShowAppoinmentTypeIcon({
    Key? key,
    required this.appointmentType,
  }) : super(key: key);

  final String appointmentType;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 30,
      width: 40,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white),
      child: appointmentType == 'V'
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 10,
                width: 10,
                child: SvgPicture.asset(
                  'assets/icon/video.svg',
                  color: Constants.secondaryColor500,
                  
                ),
              ))
          : const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(
                Icons.person,
                color: Constants.primaryColor500,
                size: 20,
              ),
          ),
    );
  }
}

class _DoctorBookingInfoWidget extends StatelessWidget {
  final DateTime bookingDate;
  const _DoctorBookingInfoWidget({Key? key, required this.bookingDate})
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
  const _DoctorProfileWidget({Key? key, required this.doctor})
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
                                imageUrl: doctor.photoUrl!,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Padding(
                                  padding: const EdgeInsets.all(26.0),
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Constants.primaryColor400),
                                    backgroundColor: Constants.primaryColor600,
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Text(
                              "${getDoctorPrefix(doctor.gender!)}${doctor.givenName} ${doctor.familyName}",
                              style: boldoHeadingTextStyle.copyWith(
                                  fontWeight: FontWeight.normal),
                            ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (doctor.specializations != null &&
                            doctor.specializations!.isNotEmpty)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.55,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  for (int i = 0;
                                      i < doctor.specializations!.length;
                                      i++)
                                    Text(
                                      "${doctor.specializations![i].description}${doctor.specializations!.length > 1 && i == 0 ? "," : ""}",
                                      style: boldoSubTextStyle.copyWith(
                                          color: Constants.otherColor100),
                                    ),
                                ],
                              ),
                            ),
                          )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                if (doctor.biography != null)
                  Text(doctor.biography!,
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
