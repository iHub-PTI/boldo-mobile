import 'package:boldo/main.dart';
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
                diagnosticReport.isEmpty
                    ? showEmptyList()
                    : showDiagnosticList()
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => NewStudy()));
        },
        backgroundColor: ConstantsV2.orange,
        label: Container(
            child: Row(
          children: [
            Text(
              'nuevo estudio',
              style: boldoSubTextMediumStyle.copyWith(
                  color: ConstantsV2.lightGrey),
            ),
            const SizedBox(
              width: 8,
            ),
            SvgPicture.asset(
              'assets/icon/upload.svg',
            ),
          ],
        )),
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
      // width: 300,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.transparent,
          height: 5,
        ),
        itemCount: diagnosticReport.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: showStudy,
      ),
    );
  }

  Widget showStudy(BuildContext context, int index) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Study(
                        id: diagnosticReport[index].id ?? '0',
                      )));
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: ClipRect(
                    child: Column(
                  children: [
                    SizedBox(
                      width: 34,
                      height: 34,
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
                    const SizedBox(height: 3),
                    Text(
                      "${diagnosticReport[index].type == "LABORATORY" ? 'lab.' : diagnosticReport[index].type == "IMAGE" ? 'img.' : diagnosticReport[index].type == "OTHER" ? 'otros' : 'desconocido'}",
                      style: boldoCorpSmallTextStyle.copyWith(
                          color: ConstantsV2.darkBlue),
                    ),
                  ],
                )),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.zero,
                            color: Constants.secondaryColor100,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0,
                                  top: 2.0,
                                  bottom: 2.0,
                                  right: 8.0),
                              child: diagnosticReport[index].sourceID ==
                                      patient.id
                                  ? Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icon/cloud.svg',
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "subido por usted",
                                          style:
                                              boldoCorpSmallTextStyle.copyWith(
                                                  color: ConstantsV2.darkBlue),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icon/inbox-in.svg',
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Boldo",
                                          style:
                                              boldoCorpSmallTextStyle.copyWith(
                                                  color: ConstantsV2.darkBlue),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          Text(
                            "${DateFormat('dd/MM/yy').format(DateTime.parse(diagnosticReport[index].effectiveDate!).toLocal())}",
                            style: boldoCorpSmallTextStyle.copyWith(
                                color: ConstantsV2.darkBlue),
                          )
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
                      // Text(
                      //   "Subido por:\n${diagnosticReport[index].source}",
                      //   style: boldoCorpMediumTextStyle.copyWith(
                      //       color: ConstantsV2.inactiveText),
                      // ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icon/attach-file.svg',
                            ),
                            const SizedBox(
                              width: 4,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
