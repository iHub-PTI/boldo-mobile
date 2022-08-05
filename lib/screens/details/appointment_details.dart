import 'package:boldo/models/Appointment.dart';
import 'package:boldo/screens/Call/video_call.dart';
import 'package:boldo/screens/doctor_profile/doctor_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../utils/helpers.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen(
      {Key? key, required this.isInWaitingRoom, required this.appointment})
      : super(key: key);
  final Appointment appointment;
  final bool isInWaitingRoom;

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
        body: Background(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 24,
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
                  'Detalles de Consulta',
                  style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.white70, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: appointment.doctor?.photoUrl == null
                                  ? SvgPicture.asset(
                                      appointment.doctor!.gender == "female"
                                          ? 'assets/images/femaleDoctor.svg'
                                          : 'assets/images/maleDoctor.svg',
                                      fit: BoxFit.cover)
                                  : CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: appointment.doctor!.photoUrl??'',
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              Padding(
                                        padding: const EdgeInsets.all(26.0),
                                        child: LinearProgressIndicator(
                                          value: downloadProgress.progress,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                      Color>(
                                                  Constants.primaryColor400),
                                          backgroundColor:
                                              Constants.primaryColor600,
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
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      "${getDoctorPrefix(appointment.doctor!.gender!)}${appointment.doctor!.familyName!}",
                                      maxLines: 1,
                                      softWrap: false,
                                      style: boldoHeadingTextStyle,
                                    ),
                                  ),
                                  if (appointment.doctor?.specializations! !=
                                          null &&
                                      appointment
                                          .doctor!.specializations!.isNotEmpty)
                                    Container(
                                      width: 200,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (int i = 0;
                                                i <
                                                    appointment.doctor!
                                                        .specializations!.length;
                                                i++)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: i == 0 ? 0 : 3.0),
                                                child: Text(
                                                  "${appointment.doctor!.specializations![i].description}${appointment.doctor!.specializations!.length > 1 && i == 0 ? "," : ""}",
                                                  style: boldoSubTextStyle,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    )
                                ]),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: const Color(0xffE5E7EB),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: TextButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorProfileScreen(
                                        doctor: appointment.doctor!),
                                  ),
                                );
                              },
                              child: const Text(
                                'Ver Perfil',
                                style: boldoHeadingTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Fecha",
                        style: boldoHeadingTextStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                          DateFormat('EEEE, dd MMMM yyyy', Localizations.localeOf(context).languageCode)
                              .format(
                                  DateTime.parse(appointment.start!).toLocal())
                              .capitalize(),
                          style: boldoSubTextStyle.copyWith(fontSize: 16)),
                      const SizedBox(height: 24),
                      const Text(
                        "Hora",
                        style: boldoHeadingTextStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${DateFormat('HH:mm').format(DateTime.parse(appointment.start!).toLocal())} horas",
                        style: boldoSubTextStyle.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (isInWaitingRoom && appointment.appointmentType == 'V')
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        child: const Text(
                          "Ingresar",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoCall(appointment: appointment),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            return Colors.white;
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isInWaitingRoom && appointment.status == "upcoming")
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                          "${appointment.appointmentType == 'V' ?'La sala de espera se abrirá a las: ${DateFormat('HH:mm').format(DateTime.parse(appointment.start!).toLocal().subtract(const Duration(minutes: 15))).capitalize()} hs, ${DateFormat(' dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(DateTime.parse(appointment.start!).toLocal()).capitalize()}':'Tiene agendada una consulta presencial en el Hospital Los Ángeles'} ")),
                ),
              const SizedBox(height: 64),
            ],
          ),
        ));
  }
}

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/decorations/ProfileScreenTopDecoration.svg',
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/decorations/ProfileBottomDecoration.svg',
            ),
          ),
          child,
        ],
      ),
    );
  }
}
