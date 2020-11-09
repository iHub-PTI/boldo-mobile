import 'package:boldo/widgets/custom_dropdown.dart';
import 'package:boldo/widgets/custom_form_input.dart';
import 'package:flutter/material.dart';

import './components/profile_image.dart';
import '../../widgets/wrapper.dart';
import '../../constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomWrapper(children: [
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
          'Mi perfil',
          style: boldoHeadingTextStyle.copyWith(fontSize: 20),
        ),
      ),
      const SizedBox(
        height: 24,
      ),
      const Center(child: ProfileImage()),
      const SizedBox(
        height: 24,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            CustomFormInput(
                label: "Nombre", validator: null, changeValueCallback: null),
            const SizedBox(
              height: 18,
            ),
            CustomFormInput(
                label: "Apellido", validator: null, changeValueCallback: null),

            //CustomDropdown(),
            const SizedBox(
              height: 18,
            ),
            CustomFormInput(
              secondaryLabel: "Opcional",
              label: "Ocupación",
              validator: null,
              changeValueCallback: null,
            ),
            const SizedBox(
              height: 18,
            ),
            CustomFormInput(
              label: "Correo electrónico",
              validator: null,
              changeValueCallback: null,
              customIcon: const Icon(Icons.calendar_today),
            ),
            const SizedBox(
              height: 18,
            ),
            CustomFormInput(
              label: "Fecha de nacimiento",
              validator: null,
              changeValueCallback: null,
            ),
            const SizedBox(
              height: 18,
            ),
            CustomFormInput(
              label: "Correo electrónico",
              validator: null,
              changeValueCallback: null,
            ),
          ],
        ),
      ),
    ]);
  }
}
