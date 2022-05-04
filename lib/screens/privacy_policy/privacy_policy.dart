import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import '../../constants.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  bool value = false;
  @override
  void initState() {
    super.initState();
  }

  Widget confirmButton() {
    return // Figma Flutter Generator FullwidthprimarymdefaultWidget - FRAME - VERTICAL
        GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.10000000149011612),
                  offset: Offset(0, 1),
                  blurRadius: 3)
            ],
            color: Color.fromRGBO(101, 207, 211, 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text(
            'Confirmar',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 1),
                fontFamily: 'Inter',
                fontSize: 17,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
                height: 1.1428571428571428),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: SvgPicture.asset('assets/Logo.svg',
            height: 30, semanticsLabel: 'BOLDO Logo'),
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 15),

          Center(
            child: Text(
              'Politicas de privacidad',
              style: boldoHeadingTextStyle.copyWith(fontSize: 20),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'ALCANCE Y CONSENTIMIENTO  ',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                text:
                    'Usted acepta esta Política de Privacidad al registrarse, acceder o utilizar los servicios, contenido, funcionalidades, tecnología o funciones disponibles de Mi Pasaporte del Ecosistema de Boldo. \n\n',
                style: TextStyle(
                  color: Color.fromRGBO(54, 65, 82, 1),
                  fontFamily: 'PT Serif',
                  fontSize: 15,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: 'RECOPILACIÓN DE INFORMACIÓN PERSONAL  \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  // TextSpan(
                  //     text: 'Boldo', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          'Recopilamos la siguiente información personal con el fin de proporcionarle el uso de los servicios de Mi Pasaporte y poder personalizar y mejorar su experiencia.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  // TextSpan(
                  //     text: 'Receta médica electronica (RME)',
                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          'Información que recopilamos automáticamente: información que nos envía su teléfono móvil u otro dispositivo de acceso: dirección IP del dispositivo, identificación del dispositivo o identificador único, tipo de dispositivo, identificación del navegador e información de geolocalización.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  // TextSpan(
                  //     text: 'Consulta médica remota (CMR)',
                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          'Información que usted nos proporciona: cualquier información que nos proporcione al usar Mi Pasaporte, incluso cuando incluye información en un formulario web, incorpora o actualiza la información de su cuenta, participa en discusiones, charlas o resoluciones de controversias en la comunidad, o cuando se comunica con nosotros para tratar acerca de los servicios Mi Pasaporte: información de contacto, como su nombre y apellido, sexo, fecha de nacimiento, número de documento de identidad, tipo de documento, dirección, número de teléfono, correo electrónico y otra información similar; información médica, como diagnósticos, recetas, medicamentos que consume, le son recetados y/o dispensados, indicaciones médicas, etc.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          'Cómo utilizamos la información personal que recopilamos  \n\n'
                              .toUpperCase()
                              .toString(),
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          'Nuestro principal objetivo al recopilar información personal es proporcionarle una experiencia segura, fluida, eficiente y personalizada. Podemos utilizar su información personal para: \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'a)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          ' Verificar su identidad, incluso durante los procesos de creación de la cuenta y de restablecimiento de la contraseña, asignación de roles en la plataforma, etc.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'b)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          ' Administrar riesgos o detectar, prevenir y/o remediar actos prohibidos o ilegales.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'c)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          '  Detectar, prevenir o remediar infracciones de las políticas o condiciones de uso aplicables.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'd)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          '  Mejorar el servicio mediante la personalización de la experiencia del usuario.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'e)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          ' Administrar y proteger nuestra infraestructura de tecnología de la información.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'f)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          ' Proporcionar mercadeo y publicidad dirigida, notificaciones de actualizaciones de servicios y ofertas promocionales.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'g)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          ' Comunicarnos en cualquier número de teléfono, mediante una llamada de voz o por medio de texto (SMS) o mensajes de correo electrónico.  \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          'Podemos contactarlo por vía electrónica o por correo postal para notificarlo de información relacionada con su cuenta, solucionar problemas con su cuenta, resolver una controversia, agrupar sus opiniones a través de encuestas o cuestionarios o de otro modo, según sea necesario para brindar servicio técnico a su cuenta. Además, podemos contactarlo para ofrecerle cupones, descuentos y promociones, y para informarle acerca de Mi Pasaporte.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          'Finalmente, podemos contactarlo según sea necesario para fines de cumplimiento de nuestras políticas, de las leyes vigentes o de cualquier acuerdo que pudiéramos tener con usted. Al contactarnos con usted por vía telefónica de la forma más eficiente posible podemos utilizar, y usted da su consentimiento para recibir, llamadas de marcación automática o pregrabadas y mensajes de texto.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'DIVULGACIÓN DE CONTENIDO   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          'Salvo la cláusula que sigue, sin su consentimiento explícito, no vendemos ni alquilamos ni divulgamos su información particular a terceros.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          'En caso de que se detecte algún servicio fraudulento, Mi Pasaporte notificará a los usuarios afectados con todos los datos del responsable.     \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          'Mi Pasaporte generará información médica estadística y podrá compartir, a su solo criterio, con autoridades de salud nacionales, departamentales y municipales. No se compartirá, salvo medidas legales especiales, información personal individualizada.      \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          'Mi Pasaporte generará información médica estadística y podrá compartir, a su solo criterio, con autoridades y organismos de salud internacionales y transnacionales. No se compartirá, salvo medidas legales especiales, información personal individualizada.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
          // Card(
          //   child: Column(
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: <Widget>[
          //           Checkbox(
          //             activeColor: const Color.fromRGBO(101, 207, 211, 1),
          //             value: value,
          //             onChanged: (bool value) {
          //               setState(() {
          //                 this.value = value;
          //               });
          //             },
          //           ), //SizedBox
          //           const Expanded(
          //             child: Text('Acepto los términos del servicio',
          //                 style:
          //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          //           ),
          //         ],
          //       ),
          //       confirmButton()
          //     ],
          //   ),
          // )
        ]),
      ),
    );
  }
}
