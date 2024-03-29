import 'package:boldo/models/Appointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../utils/helpers.dart';

class PrescriptionDetailsScreen extends StatelessWidget {
  const PrescriptionDetailsScreen({Key? key, required this.appointment})
      : super(key: key);
  final Appointment appointment;

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
          child: SingleChildScrollView(
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
                    'Detalles de la receta',
                    style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Text(
                        //   "Fecha Actual",
                        //   style: boldoHeadingTextStyle,
                        // ),
                        // const SizedBox(height: 4),
                        // Text(
                        //   "${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
                        //   style: boldoSubTextStyle.copyWith(fontSize: 16),
                        // ),
                        // const SizedBox(height: 24),
                        const Text(
                          "Doctor",
                          style: boldoHeadingTextStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                            "${getDoctorPrefix(appointment.doctor!.gender!)}${appointment.doctor!.familyName!}",
                            overflow: TextOverflow.ellipsis,
                            style: boldoSubTextStyle.copyWith(fontSize: 16)),
                        const SizedBox(height: 24),
                        const Text(
                          "Fecha de la consulta",
                          style: boldoHeadingTextStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(appointment.start!).toLocal())} horas",
                          style: boldoSubTextStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Diagnóstico",
                          style: boldoHeadingTextStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.prescriptions![0].encounter?.diagnosis??'',
                          style: boldoSubTextStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Indicaciones",
                          style: boldoHeadingTextStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.prescriptions![0].encounter?.instructions??'',
                          style: boldoSubTextStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 26),
                        for (int i = 0;
                            i < appointment.prescriptions!.length;
                            i++)
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: 
                                    Text(
                                    "Medicamento ${i + 1}",
                                    style: boldoHeadingTextStyle.copyWith(
                                      fontSize: 14,
                            
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 0,
                                    top: 7,
                                    left: 0,
                                    right: 0,
                                  ),
                                  width: double.infinity,
                                  color: const Color(0xffE5E7EB),
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Nombre",
                                  style: boldoHeadingTextStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appointment.prescriptions![i].medicationName!,
                                  style:
                                      boldoSubTextStyle.copyWith(fontSize: 16),
                                ),
                                if (appointment.prescriptions![i].instructions !=
                                    null)
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 24),
                                        const Text(
                                          "Instrucciones",
                                          style: boldoHeadingTextStyle,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          appointment
                                              .prescriptions![i].instructions??'',
                                          style: boldoSubTextStyle.copyWith(
                                              fontSize: 16),
                                        ),
                                      ]),
                                const SizedBox(height: 24),
                              ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
