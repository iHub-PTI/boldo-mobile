import 'package:boldo/screens/dashboard/tabs/components/item_menu.dart';
import 'package:boldo/screens/my_account/delete_account_screen.dart';
import 'package:boldo/screens/privacy_policy/privacy_policy.dart';
import 'package:boldo/screens/profile/password_reset_screen.dart';
import 'package:boldo/screens/terms_of_services/terms_of_services.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final List<ItemMenu> items = [
    const ItemMenu(
      image: 'assets/icon/shield-check.svg',
      title: 'Políticas de privacidad',
      page: PrivacyPolicy(),
    ),
    const ItemMenu(
      image: 'assets/icon/document-text.svg',
      title: 'Términos de servicio',
      page: TermsOfServices(),
    ),
    //TODO: not implemented for dependents
    const ItemMenu(
      image: 'assets/icon/edit.svg',
      title: 'Cambiar contraseña',
      page: PasswordResetScreen(),
    ),
    const ItemMenu(
      image: 'assets/icon/delete.svg',
      title: 'Eliminar cuenta',
      page: DeleteAccount(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomWrapper(children: [
      const SizedBox(height: 20),
      BackButtonLabel(
        labelText: 'Mi cuenta',
      ),
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            color: Colors.white,
            child: Container(
              alignment: Alignment.topLeft,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length * 2 - 1,
                padding: const EdgeInsets.symmetric(vertical: 4),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  if (index.isOdd) {
                    return const Divider(); // Divider between items
                  }

                  return _buildItemList(context, (index ~/ 2), items);
                },
                physics: const ClampingScrollPhysics(),
              ),
            ),
          ),
        ),
      )
    ]);
  }
}

Widget _buildItemList(BuildContext context, int index, List<ItemMenu> items) {
  return items[index];
}
