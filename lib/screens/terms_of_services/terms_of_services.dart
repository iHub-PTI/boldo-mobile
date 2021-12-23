import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

import '../../widgets/wrapper.dart';

import '../../constants.dart';

class TermsOfServices extends StatefulWidget {
  const TermsOfServices({Key key}) : super(key: key);

  @override
  _TermsOfServicesState createState() => _TermsOfServicesState();
}

class _TermsOfServicesState extends State<TermsOfServices> {
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
    return CustomWrapper(children: [
      const SizedBox(height: 24),
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
          'Término de servicio',
          style: boldoHeadingTextStyle.copyWith(fontSize: 20),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          text: const TextSpan(
            text:
                '   El presente es un documento importante que usted debe leer atentamente antes de decidir utilizar los servicios de Boldo. Al usar los servicios del sitio Boldo usted acepta las condiciones de uso de la plataforma que se describen a continuación. \n'
                '   El presente documento es un contrato entre usted y Fundación Parque Tecnológico Itaipú (PTI-PY) (en adelante Boldo), propietaria de la marca registrada Boldo. Los términos del presente documento tienen carácter de contrato de adhesión y se aplica al relacionamiento entre Boldo y Ud. como consecuencia del uso de los servicios ofrecidos por Boldo. El solo hecho del uso del acceso y uso de los servicios Boldo implica que usted acepta todos los términos y condiciones contenidos en este documento.\n'
                '   Boldo se reserva el derecho de modificar el contenido del presente acuerdo , en cualquier momento y a su entero criterio, mediante la publicación de una nueva versión de este en el sitio web de Boldo. La versión revisada entrará en vigor al momento de su publicación. Es responsabilidad exclusiva suya la revisión frecuente de este documento. \n'
                '   Usted es el único responsable de comprender y dar cumplimiento a todas y cada una de las leyes, normas y regu- laciones que se le puedan aplicar en relación con el uso que haga de los servicios de Boldo, incluyendo, pero sin limitarse a, toda actividad relacionada a la generación de recetas médicas, fichas médicas, registro de medicamentos, farmacias, laboratorios, etc. y cualquier otro servicios tangibles e intangibles. \n\n',
            style: TextStyle(
              color: Color.fromRGBO(54, 65, 82, 1),
              fontFamily: 'PT Serif',
              fontSize: 20,
              letterSpacing: 0,
              fontWeight: FontWeight.normal,
              height: 1.5,
            ),
            children: <TextSpan>[
              TextSpan(
                  text: 'DEFINICIONES \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Boldo', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      ' es la proveedora de los servicios que se ofrecen a través de una plataforma de gestión y automatiza- ción de recetas médicas, consultas médicas, fichas médicas y otros servicios conexos, que serán descritos a lo largo de este documento y sus anexos.  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Receta médica electronica (RME)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      ' Es la receta médica con validez legal en el país que permite generar Bol- do de manera electrónica.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Consulta médica remota (CMR)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '  Es el servicio que ofrece Boldo para realizar consultas médicas de una forma no presencial (remota)    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Médico',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '  Es aquel usuario de Boldo que utilizará los servicios para generar las RME y atender las CMR. \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Paciente',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '  Es aquel usuario de Boldo que tiene acceso a las recetas médicas que le fueran emitidas tanto de forma presencial como remota por los Médicos  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Farmacéutico',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '  Es aquel usuario de Boldo que tiene acceso a las recetas médicas para ser dispensadas a los pacientes.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Conducta inapropiada',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '   Es aquella que atenta contra las buenas costumbres y convivencia de los distintos usuarios de Boldo, la propia plataforma y los miembros del staff.  \n\n',
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
    ]);
  }
}
