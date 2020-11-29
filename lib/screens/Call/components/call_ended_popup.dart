import 'package:boldo/utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:boldo/models/Appointment.dart';
import 'package:boldo/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<bool> callEndedPopup(
    {@required BuildContext context, @required Appointment appointment}) async {
  return showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (
        BuildContext context,
      ) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Center(
            child: Card(
              elevation: 11,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Consulta Finalizada",
                      style: TextStyle(
                          color: Constants.otherColor100,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 72,
                        width: 72,
                        child: appointment.doctor.photoUrl == null
                            ? SvgPicture.asset(
                                appointment.doctor.gender == "female"
                                    ? 'assets/images/femaleDoctor.svg'
                                    : 'assets/images/maleDoctor.svg',
                                fit: BoxFit.cover)
                            : CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: appointment.doctor.photoUrl,
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
                    const SizedBox(height: 12),
                    Text(
                      "${getDoctorPrefix(appointment.doctor.gender)} ${appointment.doctor.familyName}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Constants.extraColor400,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "FIX ME! (SPECIALIZATION GOES HERE)",
                      textAlign: TextAlign.center,
                      style: boldoSubTextStyle,
                    ),
                    const SizedBox(height: 24),
                    Align(
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
                              DateFormat('EEEE, dd MMMM yyyy')
                                  .format(DateTime.parse(appointment.start)
                                      .toLocal())
                                  .capitalize(),
                              style: boldoSubTextStyle.copyWith(fontSize: 16)),
                          const SizedBox(height: 24),
                          const Text(
                            "Hora",
                            style: boldoHeadingTextStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${DateFormat('HH:mm').format(DateTime.parse(appointment.start).toLocal())} horas",
                            style: boldoSubTextStyle.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Constants.primaryColor500,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Aceptar")),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      });
}
