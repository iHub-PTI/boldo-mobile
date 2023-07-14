import 'package:boldo/widgets/back_button.dart';
import 'package:flutter/material.dart';

import '../../widgets/wrapper.dart';

import '../../constants.dart';

class TermsOfServices extends StatefulWidget {
  const TermsOfServices({Key? key}) : super(key: key);

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
      BackButtonLabel(
        labelText: 'Término de servicio',
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          text: const TextSpan(
            text:
                '   El presente es un documento importante que usted debe leer atentamente antes de decidir utilizar los servicios de Boldo. Al usar los servicios del sitio Boldo usted acepta las condiciones de uso de la plataforma que se describen a continuación. \n'
                '   El presente documento es un contrato entre usted y Fundación Parque Tecnológico Itaipú (PTI-PY) (en adelante Boldo), propietaria de la marca registrada Boldo. Los términos del presente documento tienen carácter de contrato de adhesión y se aplica al relacionamiento entre Boldo y Ud. como consecuencia del uso de los servicios ofrecidos por Boldo. El solo hecho del uso del acceso y uso de los servicios Boldo implica que usted acepta todos los términos y condiciones contenidos en este documento.\n'
                '   Boldo se reserva el derecho de modificar el contenido del presente acuerdo, en cualquier momento y a su entero criterio, mediante la publicación de una nueva versión de este en el sitio web de Boldo. La versión revisada entrará en vigor al momento de su publicación. Es responsabilidad exclusiva suya la revisión frecuente de este documento. \n'
                '   Usted es el único responsable de comprender y dar cumplimiento a todas y cada una de las leyes, normas y regulaciones que se le puedan aplicar en relación con el uso que haga de los servicios de Boldo, incluyendo, pero sin limitarse a, toda actividad relacionada a la generación de recetas médicas, fichas médicas, registro de medicamentos, farmacias, laboratorios, etc. y cualquier otro servicios tangibles e intangibles. \n\n',
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
                      ' es la proveedora de los servicios que se ofrecen a través de una plataforma de gestión y automatización de recetas médicas, consultas médicas, fichas médicas y otros servicios conexos, que serán descritos a lo largo de este documento y sus anexos.  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Receta médica electronica (RME).',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      ' Es la receta médica con validez legal en el país que permite generar Boldo de manera electrónica.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Consulta médica remota (CMR).',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '  Es el servicio que ofrece Boldo para realizar consultas médicas de una forma no presencial (remota).    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Médico.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '  Es aquel usuario de Boldo que utilizará los servicios para generar las RME y atender las CMR. \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Paciente.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '  Es aquel usuario de Boldo que tiene acceso a las recetas médicas que le fueran emitidas tanto de forma presencial como remota por los Médicos.  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Farmacéutico.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '  Es aquel usuario de Boldo que tiene acceso a las recetas médicas para ser dispensadas a los pacientes.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Conducta inapropiada.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      '  Es aquella que atenta contra las buenas costumbres y convivencia de los distintos usuarios de Boldo, la propia plataforma y los miembros del staff.  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Conducta fraudulenta.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  '  Es aquella que está orientada al incumplimiento, por parte de los usurarios, con los términos del presente documento y/o la generación de contenido ilegal o fraudulento derivado de servicios que son proporcionados por la plataforma de Boldo.  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'GENERALIDADES \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Plataforma de gestión abierta.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  '  Boldo es una plataforma de gestión de servicios y relacionados a medicina y telemedicina de uso general, abierta y apta para mayores de edad. Por lo tanto, queda prohibida utilización de la plataforma para fines para los que no fue construida. Queda prohibido, el uso de esta para difusión, promoción y comercialización de productos de contenido sexual tales como: pornografía, prostitución, artículos y juguetes sexuales, armas de fuego, cigarrillos y drogas ilegales, contenido de terceros que estén protegidos por propiedad intelectual y que no tengan autorización de comercialización, etc. Finalmente, Boldo se reserva el derecho de eliminar contenido que a su solo criterio sea considerado como inapropiado para la tienda.  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Responsabilidad.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  '  Boldo no tiene responsabilidad alguna en relación con las recetas emitidas, despachadas y/o consultas médicas, realizadas a través de la plataforma. El Médico y Farmacéutico son los únicos responsables por los servicios que él brindan a través de Boldo. De igual manera, el Paciente es el único responsable por usar correctamente los servicios destinados a él en la plataforma. Los únicos responsables por las transacciones de receta, consulta y otros servicios son los usuarios. Boldo no tiene responsabilidad alguna en las transacciones entre las partes citadas, ni en la calidad de los servicios médicos de consulta, receta, etc. ni en el cumplimiento o veracidad de la descripción de estos.  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'CONDICIONES DE LOS SERVICIOS OFRECIDOS POR BOLDO \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Boldo provee los siguientes servicios a médicos: \n\n',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'a)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Capacidad de generar y emitir recetas médicas electrónicas a través del módulo de RME.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'b)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Capacidad de agendar y atender a los pacientes de forma remota a través el módulo de CMR.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'c)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Catálogo de medicamentos precargados y configurados en la plataforma.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'd)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Servicio de completado automático de datos de pacientes vía comunicación con servicios del Departamento de Identificaciones de la Policía Nacional.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Requisitos y responsabilidades de médicos: \n\n',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'a)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Pueden ser médicos personas físicas mayores de edad, habilitadas legalmente por el MSP.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'b)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' El médico deberá crear un logín para identificarse en la plataforma. En tal sentido, Boldo podrá disponer de los mecanismos de gestión de usuarios, alternativamente podrá poner a disposición mecanismos que permitan enlazar el login de Boldo a otros sistemas de gestión de usuarios.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'c)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' El médico deberá completar con sus datos personales el formulario de registro. Boldo podrá solicitar, pero no limitarse a, los siguientes datos personales: Nombres y Apellidos, Sexo, Nacionalidad, Edad, Tipo de Documento, Número de Cedula de Identidad, Número de RUC, Dirección, Departamento, Ciudad, Número de registro profesional, Teléfonos y Correo Electrónico.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'd)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' El médico es el único responsable por la carga veraz y correcta de: sus datos personales, las recetas, los diagnósticos e indicaciones médicas, los medicamentos que indican y emiten.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Boldo provee los siguientes servicios a farmacéuticos: \n\n',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'a)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Capacidad dispensar los medicamentos a los pacientes de forma remota a través el módulo de RME.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'b)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Servicio de completado automático de datos de paciente a quienes se emitió la receta electrónica.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Requisitos y responsabilidades de farmacéuticos: \n\n',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'a)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Pueden ser farmacéuticos personas físicas mayores de edad, habilitadas por sus respetivas farmacias.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'b)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' El farmacéutico deberá crear un logín para identificarse en la plataforma. En tal sentido, Boldo podrá disponer de los mecanismos de gestión de usuarios, alternativamente podrá poner a disposición mecanismos que permitan enlazar el login de Boldo a otros sistemas de gestión de usuarios.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'c)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' El farmacéutico deberá utilizar un logín genérico de toda la farmacia a la cual está asignado para acceder a ella.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'd)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' El farmacéutico es el único responsable por la carga veraz y correcta de sus datos personales y recetas dispensadas a pacientes.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Boldo provee los siguientes servicios a pacientes: \n\n',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'a)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Capacidad para visualizar las recetas que le fueron emitidas de forma remota a través el módulo de RME.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'b)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Capacidad para agendar y consultar con médicos en forma remota a través del módulo de CMR.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'Requisitos y responsabilidades de pacientes: \n\n',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'a)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' Pueden ser pacientes personas físicas mayores de edad.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'b)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' El paciente deberá crear un logín para identificarse en la plataforma. En tal sentido, Boldo podrá disponer de los mecanismos de gestión de usuarios, alternativamente podrá poner a disposición mecanismos que permitan enlazar el login de Boldo a otros sistemas de gestión de usuarios.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'c)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' El paciente deberá completar con sus datos personales el formulario de registro. Boldo podrá solicitar, pero no limitarse a, los siguientes datos personales: Nombres y Apellidos, Sexo, Nacionalidad, Edad, Tipo de Documento, Número de Cedula de Identidad, Dirección, Departamento, Ciudad, Teléfonos y Correo Electrónico.   \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'd)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  ' El paciente es el único responsable por el uso correcto de la herramienta para sus consultas, recetas médicas y medicamentos que le fueron recetados y dispensados.    \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text: 'CANCELACIÓN DE CUENTAS \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text:
                  'Boldo se reserva el derecho de cancelar las cuentas de usuarios a su entera discreción. Sin embargo, se destaca que incurrir en conductas inapropiadas y/o fraudulentas son causales importantes de cancelación de cuentas y el cese de los servicios de Boldo. Boldo se reserva el derecho de advertir y/o abrir sumario a usuarios previamente a la cancelación de cuentas.  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text:
                  'En caso de cancelación de cuentas por conductas inapropiadas o fraudulentas Boldo pierden cualquier reclamo que puedan hacer a Boldo por cualquier via: administrativa, civil, penal y/o defensa al consumidor. De igual manera, los usuarios con cuentas canceladas pierden el derecho de reclamar indemnización alguna.  \n\n',
                  style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(
                  text:
                  'Boldo se reserva el derecho de hacer denuncias penales, civiles y/o defensa al consumidor a usuarios que hayan incurrido en conductas inapropiadas y/o fraudulentas.  \n\n',
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
