import 'package:boldo/constants.dart';
import 'package:boldo/screens/dashboard/tabs/components/item_menu.dart';
import 'package:boldo/screens/privacy_policy/privacy_policy.dart';
import 'package:boldo/screens/terms_of_services/terms_of_services.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({Key? key}) : super(key: key);

  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  @override
  Widget build(BuildContext context) {
    return CustomWrapper(children: [
      const SizedBox(height: 20),
      BackButtonLabel(
        labelText: 'Eliminar cuenta',
      ),
      SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Container(
            alignment: Alignment.topLeft,
            child: Column(children: [
              const Text(
                  'Lamentamos mucho saber que has decidido eliminar tu cuenta. Queremos asegurarnos de que este proceso se realice de manera segura y eficiente.'),
              const SizedBox(
                height: 25,
              ),
              RichText(
                  text: TextSpan(
                      style: boldoCorpSmallSTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ConstantsV2.activeText),
                      children: [
                    const TextSpan(
                        text:
                            'El proceso de eliminación de la cuenta tomará aproximadamente'),
                    const TextSpan(
                        style: TextStyle(color: ConstantsV2.orange),
                        text: ' 30 días '),
                    const TextSpan(
                        text:
                            'para completarse. Una vez finalizado este proceso, recibirás un correo electrónico de confirmación.')
                  ])),
              const SizedBox(
                height: 25,
              ),
              const Text(
                  'Durante este período, queremos informarte que los siguientes datos asociados a tu cuenta serán eliminados de nuestros sistemas:'),
              const SizedBox(
                height: 25,
              ),
              DefaultTextStyle(
                  style: boldoCorpSmallSTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ConstantsV2.activeText,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '1. Información personal (nombre, dirección, fecha de nacimiento, etc.).'),
                      Text('2. Datos de inicio de sesión y credenciales.'),
                      Text('3. Historial de actividad y uso de la aplicación.'),
                      Text(
                          '4. Cualquier otra información relacionada específicamente con tu cuenta.'),
                    ],
                  )),
              const SizedBox(
                height: 25,
              ),
              const Text(
                  'Por favor, ten en cuenta que esta acción es irreversible una vez completada. Si has reconsiderado esta decisión o necesitas alguna asistencia adicional, no dudes en contactarnos antes de que se complete el proceso de eliminación al correo info@bol.do')
            ]),
          ),
        ),
      )
    ]);
  }
}

Widget _buildItemList(BuildContext context, int index, List<ItemMenu> items) {
  return items[index];
}
