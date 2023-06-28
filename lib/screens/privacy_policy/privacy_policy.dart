import 'package:boldo/widgets/back_button.dart';
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
        actions: [],
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SvgPicture.asset('assets/Logo.svg',
              semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const SizedBox(height: 16),
          BackButtonLabel(
            labelText: 'Políticas de privacidad',
          ),
          const SizedBox(height: 24),
          const Padding(
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
                    'Usted acepta esta Política de Privacidad al registrarse, acceder o utilizar los servicios, contenido, funcionalidades, tecnología o funciones disponibles de Boldo. \n\n',
                style: const TextStyle(
                  color: Color.fromRGBO(54, 65, 82, 1),
                  fontFamily: 'PT Serif',
                  fontSize: 15,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
                children: <TextSpan>[
                  const TextSpan(
                      text: 'RECOPILACIÓN DE INFORMACIÓN PERSONAL  \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  // TextSpan(
                  //     text: 'Boldo', style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          'Recopilamos la siguiente información personal con el fin de proporcionarle el uso de los servicios de Boldo y poder personalizar y mejorar su experiencia.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  // TextSpan(
                  //     text: 'Receta médica electronica (RME)',
                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          'Información que recopilamos automáticamente: información que nos envía su teléfono móvil u otro dispositivo de acceso: dirección de IP del dispositivo, identificación del dispositivo o identificador único, tipo de dispositivo, identificación del navegador e información de geolocalización.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  // TextSpan(
                  //     text: 'Consulta médica remota (CMR)',
                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          'Información que usted nos proporciona: cualquier información que nos proporcione al usar Boldo, incluso cuando incluye información en un formulario web, incorpora o actualiza la información de su cuenta, participa en discusiones, charlas o resoluciones de controversias en la comunidad, o cuando se comunica con nosotros para tratar acerca de los servicios Boldo: información de contacto, como su nombre y apellido, sexo, fecha de nacimiento, número de documento de identidad, tipo de documento, dirección, número de teléfono, correo electrónico y otra información similar; información médica, como diagnósticos, recetas, medicamentos que consume, le son recetados y/o dispensados, indicaciones médicas, etc.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                      'También podemos recopilar información de usted o acerca de usted de otras fuentes, como por ejemplo, a través de comunicaciones con nosotros, lo que incluye a nuestro equipo de soporte técnico, sus resultados cuando responde una encuesta y sus interacciones con los miembros del equipo de Boldo u otras empresas (sujeto a sus políticas de privacidad y a las leyes vigentes). Además, para fines de calidad y capacitación o por su propia protección, Boldo puede controlar o grabar las conversaciones telefónicas que tengamos con usted o con cualquier persona que actúe en su nombre. Al comunicarse con el soporte técnico de Boldo, usted reconoce que la comunicación podría ser escuchada, controlada o grabada sin notificación o advertencia.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                      'Puede optar por proporcionarnos acceso a cierta información personal almacenada por terceros, tales como sitios de redes sociales (por ejemplo, Facebook y Twitter). La información que podemos recibir varía según el sitio y es controlada por dicho sitio. Al asociar una cuenta administrada por un tercero con su cuenta de Boldo y al autorizar a Boldo a tener acceso a esta información, usted acepta que Boldo pueda recopilar, almacenar y utilizar esta información de acuerdo con esta Política de Privacidad.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                      'Autenticación y detección de fraudes: A fin de poder protegerlo contra fraudes y el mal uso de su información personal, podemos recopilar información acerca de usted y de sus interacciones con el servicio de Boldo.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          'Cómo utilizamos la información personal que recopilamos  \n\n'
                              .toUpperCase()
                              .toString(),
                      style: const TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                          'Nuestro principal objetivo al recopilar información personal es proporcionarle una experiencia segura, fluida, eficiente y personalizada. Podemos utilizar su información personal para: \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text: 'a)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          ' Verificar su identidad, incluso durante los procesos de creación de la cuenta y de restablecimiento de la contraseña, asignación de roles en la plataforma, etc.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text: 'b)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          ' Administrar riesgos o detectar, prevenir y/o remediar actos prohibidos o ilegales.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text: 'c)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          '  Detectar, prevenir o remediar infracciones de las políticas o condiciones de uso aplicables.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text: 'd)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          '  Mejorar el servicio mediante la personalización de la experiencia del usuario.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text: 'e)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          ' Administrar y proteger nuestra infraestructura de tecnología de la información.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text: 'f)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          ' Proporcionar mercadeo y publicidad dirigida, notificaciones de actualizaciones de servicios y ofertas promocionales.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text: 'g)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          ' Comunicarnos en cualquier número de teléfono, mediante una llamada de voz o por medio de texto (SMS) o mensajes de correo electrónico.  \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                          'Podemos contactarlo por vía electrónica o por correo postal para notificarlo de información relacionada con su cuenta, solucionar problemas con su cuenta, resolver una controversia, agrupar sus opiniones a través de encuestas o cuestionarios o de otro modo, según sea necesario para brindar servicio técnico a su cuenta. Además, podemos contactarlo para ofrecerle cupones, descuentos y promociones, y para informarle acerca de Boldo.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                          'Finalmente, podemos contactarlo según sea necesario para fines de cumplimiento de nuestras políticas, de las leyes vigentes o de cualquier acuerdo que pudiéramos tener con usted. Al contactarnos con usted por vía telefónica de la forma más eficiente posible podemos utilizar, y usted da su consentimiento para recibir, llamadas de marcación automática o pregrabadas y mensajes de texto.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text: 'DIVULGACIÓN DE CONTENIDO   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                          'Salvo la cláusula que sigue, sin su consentimiento explícito, no vendemos ni alquilamos ni divulgamos su información particular a terceros.   \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                          'En caso de que se detecte algún servicio fraudulento, Boldo notificará a los usuarios afectados con todos los datos del responsable.     \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                          'Boldo generará información médica estadística y podrá compartir, a su solo criterio, con autoridades de salud nacionales, departamentales y municipales. No se compartirá, salvo medidas legales especiales, información personal individualizada.      \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                          'Boldo generará información médica estadística y podrá compartir, a su solo criterio, con autoridades y organismos de salud internacionales y transnacionales. No se compartirá, salvo medidas legales especiales, información personal individualizada.    \n\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  const TextSpan(
                      text:
                      'Boldo generará información estadística de medicamentos recetados y/o dispensados y podrá comercializar y/o compartir, a su solo criterio, con empresas farmacéuticas y laboratorios. No se compartirá, salvo medidas legales especiales, información personal individualizada.    \n\n',
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
