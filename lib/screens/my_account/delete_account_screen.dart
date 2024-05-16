import 'package:boldo/constants.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/wrapper.dart';
import 'package:flutter/material.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({Key? key}) : super(key: key);

  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      children: [
        const SizedBox(height: 20),
        BackButtonLabel(
          labelText: 'Eliminar cuenta',
        ),
        SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: boldoCorpSmallSTextStyle.copyWith(
                      fontSize: 16,
                      color: ConstantsV2.activeText,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'Lamentamos mucho saber que has decidido eliminar tu cuenta. Queremos asegurarnos de que este proceso se realice de manera segura y eficiente.\n',
                      ),
                      const WidgetSpan(
                        child: SizedBox(
                          height: 30,
                        ),
                      ),
                      const TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'El proceso de eliminación de la cuenta tomará aproximadamente',
                          ),
                          TextSpan(
                            style: TextStyle(color: ConstantsV2.orange),
                            text: ' 30 días ',
                          ),
                          TextSpan(
                            text:
                                'para completarse. Una vez finalizado este proceso, recibirás un correo electrónico de confirmación.\n',
                          ),
                        ],
                      ),
                      const WidgetSpan(
                        child: SizedBox(
                          height: 30,
                        ),
                      ),
                      const TextSpan(
                        text:
                            'Durante este período, queremos informarte que los siguientes datos asociados a tu cuenta serán eliminados de nuestros sistemas: \n',
                      ),
                      const WidgetSpan(
                        child: SizedBox(
                          height: 30,
                        ),
                      ),
                      const TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        text:
                            '1. Información personal (nombre, dirección, fecha de nacimiento, etc.).\n2. Datos de inicio de sesión y credenciales. \n3. Historial de actividad y uso de la aplicación. \n4. Cualquier otra información relacionada específicamente con tu cuenta. \n',
                      ),
                      const WidgetSpan(
                        child: SizedBox(
                          height: 30,
                        ),
                      ),
                      const TextSpan(
                        text:
                            'Por favor, ten en cuenta que esta acción es irreversible una vez completada. Si has reconsiderado esta decisión o necesitas alguna asistencia adicional, no dudes en contactarnos antes de que se complete el proceso de eliminación al correo ',
                      ),
                      const TextSpan(
                        style: TextStyle(fontWeight: FontWeight.w500),
                        text: 'info@bol.do',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Quiero eliminar mi cuenta'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
