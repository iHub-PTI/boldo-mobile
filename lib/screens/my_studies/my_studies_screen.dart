import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/DiagnosticReport.dart';
import 'estudy_screen.dart';
import 'new_study.dart';

class MyStudies extends StatefulWidget {
  MyStudies({Key? key}) : super(key: key);

  @override
  State<MyStudies> createState() => _MyStudiesState();
}

class _MyStudiesState extends State<MyStudies> {
  bool _loading = true;
  bool _error = false;
  List<DiagnosticReport> diagnosticReport = [];
  @override
  void initState() {
    BlocProvider.of<MyStudiesBloc>(context).add(GetPatientStudiesFromServer());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: BlocListener<MyStudiesBloc, MyStudiesState>(
          listener: (context, state) {
            if (state is Loading) {
              _loading = true;
              _error = false;
              print('loading');
            }
            if (state is DiagnosticLoaded) {
              print('success DiagnosticLoaded');
              _loading = false;
              _error = false;
              setState(() {
                diagnosticReport = state.studiesList;
              });
            }

            if (state is Failed) {
              print('algo falló: ${state.msg}');
              _loading = false;
              _error = true;
              setState(() {});
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("Falló la obtención de estudios")));
            }
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    'Estudios',
                    style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                  ),
                ),
                Text(
                  'Subí y consultá resultados de estudios provenientes de varias fuentes.',
                  style: boldoHeadingTextStyle.copyWith(fontSize: 12),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'Mis estudios',
                  style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                ),
                 const SizedBox(
                  height: 15,
                ),
                diagnosticReport.isEmpty ? showEmptyList() : showDiagnosticList()
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NewStudy()));
        },
        backgroundColor: ConstantsV2.orange,
        label: Container(
            child: Row(
              children: [
                Text('nuevo estudio', style: boldoSubTextMediumStyle.copyWith(color: ConstantsV2.lightGrey),),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset('assets/icon/upload.svg',),
              ],
            )
        ),
      ),
    );
  }

  showEmptyList() {
    return Column(
      children: [
        if (_loading)
          const Text('Cargando...')
        else if (_error)
          const Text('Error')
        else ...[
          const Text('Aun no tenés estudios para visualizar'),
          SvgPicture.asset('assets/images/empty_studies.svg', fit: BoxFit.cover)
        ]
      ],
    );
  }

  Widget showDiagnosticList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: ListView.builder(
        itemCount: diagnosticReport.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: showStudy,
      ),
    );
  }


Widget showStudy(BuildContext context, int index) {
  // return Text(' - ${diagnostic.descriptio coextn} (${diagnostic.effectiveDate})',
  //     style: boldoHeadingTextStyle.copyWith(fontSize: 12));
  return Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 4),
    child: InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => Study(id: diagnosticReport[index].id?? '0',)));
      },
      child: Container(
        padding: const EdgeInsets.only(top: 8, left: 8),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Estudio reciente",
                  style: boldoCorpSmallTextStyle.copyWith(
                      color: ConstantsV2.darkBlue),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Text(
                    "${DateFormat('dd/MM/yy').format(DateTime.parse(diagnosticReport[index].effectiveDate!).toLocal())}",
                    style: boldoCorpSmallTextStyle.copyWith(
                        color: ConstantsV2.darkBlue),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: ClipOval(
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: SvgPicture.asset(
                        diagnosticReport[index].type == "LABORATORY"
                            ? 'assets/icon/lab.svg'
                            : diagnosticReport[index].type == "IMAGE"
                                ? 'assets/icon/image.svg'
                                : diagnosticReport[index].type == "OTHER"
                                    ? 'assets/icon/other.svg'
                                    : 'assets/images/LogoIcon.svg',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // For a future Laboratory's Name
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "${diagnosticReport[index].description}",
                      style: boldoCorpMediumTextStyle.copyWith(
                          color: ConstantsV2.inactiveText),
                    ),
                    Text(
                      "Subido por ${diagnosticReport[index].source}",
                      style: boldoCorpMediumTextStyle.copyWith(
                          color: ConstantsV2.inactiveText),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Container(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/attach-file.svg',
                          ),
                          Text(
                            "${diagnosticReport[index].attachmentNumber} ${diagnosticReport[index].attachmentNumber == "1" ? "archivo adjunto" : "archivos adjuntos"}",
                            style: boldoCorpSmallTextStyle.copyWith(
                                color: ConstantsV2.darkBlue),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
          ],
        ),
      ),
    ),
  );
}
}