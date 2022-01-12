import 'package:boldo/screens/profile/actions/sharedActions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_form_button.dart';
import '../../widgets/wrapper.dart';
import '../../widgets/custom_form_input.dart';
import '../../provider/user_provider.dart';
import '../../constants.dart';

class AddressScreen extends StatefulWidget {
  AddressScreen({Key? key}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _validate = false;
  bool loading = false;
  late String street, neighborhood, city, addressDescription;

  final _formKey = GlobalKey<FormState>();

  Future<void> _updateLocation() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _validate = true;
      });
      return;
    }

    _formKey.currentState!.save();

    Provider.of<UserProvider>(context, listen: false)
        .clearProfileFormMessages();
    setState(() {
      loading = true;
    });
    Map<String, String> updateResponse = await updateProfile(context: context);
    Provider.of<UserProvider>(context, listen: false).updateProfileEditMessages(
        updateResponse["successMessage"]!, updateResponse["errorMessage"]!);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return CustomWrapper(
      children: [
        const SizedBox(height: 20),
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
            'Dirección',
            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            autovalidateMode:
                _validate ? AutovalidateMode.always : AutovalidateMode.disabled,
            key: _formKey,
            child: Column(
              children: [
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return CustomFormInput(
                      initialValue: data ?? "",
                      label: "Calle",
                      secondaryLabel: "Opcional",
                      onChanged: (String val) =>
                          userProvider.setUserData(street: val),
                    );
                  },
                  selector: (buildContext, userProvider) =>
                      userProvider.getStreet??'',
                ),
                const SizedBox(height: 20),
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return CustomFormInput(
                      initialValue: data ?? "",
                      label: "Barrio",
                      secondaryLabel: "Opcional",
                      onChanged: (String val) =>
                          userProvider.setUserData(neighborhood: val),
                    );
                  },
                  selector: (buildContext, userProvider) =>
                      userProvider.getNeighborhood??'',
                ),
                const SizedBox(height: 20),
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return CustomFormInput(
                      initialValue: data ?? "",
                      label: "Ciudad",
                      secondaryLabel: "Opcional",
                      onChanged: (String val) =>
                          userProvider.setUserData(city: val),
                    );
                  },
                  selector: (buildContext, userProvider) =>
                      userProvider.getCity??'',
                ),
                const SizedBox(height: 20),
                Selector<UserProvider, String>(
                  builder: (_, data, __) {
                    return CustomFormInput(
                      initialValue: data ?? "",
                      maxLines: 6,
                      label: "Referencia",
                      secondaryLabel: "Opcional",
                      onChanged: (String val) =>
                          userProvider.setUserData(addressDescription: val),
                    );
                  },
                  selector: (buildContext, userProvider) =>
                      userProvider.getAddressDescription??'',
                ),
                const SizedBox(height: 26),
                SizedBox(
                  child: Column(
                    children: [
                      if (userProvider.profileEditErrorMessage != null)
                        Text(
                          userProvider.profileEditErrorMessage??'',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Constants.otherColor100,
                          ),
                        ),
                      if (userProvider.profileEditSuccessMessage != null)
                        Text(
                          userProvider.profileEditSuccessMessage??'',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Constants.primaryColor600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                CustomFormButton(
                  loading: loading,
                  text: "Guardar",
                  actionCallback: _updateLocation,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
