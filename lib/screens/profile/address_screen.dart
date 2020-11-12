import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/wrapper.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_form_input.dart';

import '../../constants.dart';

class AddressScreen extends StatefulWidget {
  AddressScreen({Key key}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
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
                validator: null,
                changeValueCallback: null,
              ),
              const SizedBox(
                height: 18,
              ),
              CustomFormInput(
                  label: "Contraseña nueva",
                  validator: null,
                  changeValueCallback: null),
              const SizedBox(
                height: 18,
              ),
              CustomFormInput(
                  maxLines: 5,
                  label: "Confirmar contraseña nueva",
                  validator: null,
                  changeValueCallback: null),
              const SizedBox(
                height: 24,
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
