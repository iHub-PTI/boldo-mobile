import 'package:flutter/material.dart';

import '../../widgets/wrapper.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_form_input.dart';

import '../../constants.dart';

class PasswordResetScreen extends StatefulWidget {
  PasswordResetScreen({Key key}) : super(key: key);

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      children: [
        const SizedBox(
          height: 18,
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
            'Contraseña',
            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(
          height: 18,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              CustomFormInput(
                label: "Contraseña actual",
                customSVGIcon: "assets/icon/eyeoff.svg",
                validator: null,
                obscureText: true,
                changeValueCallback: null,
              ),
              const SizedBox(
                height: 48,
              ),
              CustomFormInput(
                label: "Contraseña nueva",
                customSVGIcon: "assets/icon/eyeoff.svg",
                validator: null,
                obscureText: true,
                changeValueCallback: null,
              ),
              const SizedBox(
                height: 18,
              ),
              CustomFormInput(
                label: "Confirmar contraseña nueva",
                customSVGIcon: "assets/icon/eyeoff.svg",
                validator: null,
                obscureText: true,
                changeValueCallback: null,
              ),
              const SizedBox(
                height: 56,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Constants.primaryColor500,
                  ),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => BookingConfirmScreen(
                    //             bookingDate: DateTime.now(),
                    //             bookingHour: _selectedBookingHour,
                    //           )),
                    // );
                  },
                  child: const Text("Guardar"),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
