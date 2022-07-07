import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/DiagnosticReport.dart';
import 'estudy_screen.dart';

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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {},
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
                  const Text(""),
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
                        Text(
                          "${diagnosticReport[index].type}",
                          style: boldoCorpSmallTextStyle.copyWith(
                              color: ConstantsV2.darkBlue),
                        ),
                      ],
                    )),
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
                        "Subido por:\n${diagnosticReport[index].source}",
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
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /*
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            // TODO redirect to medical study page
                          },
                          child: Card(
                              margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
                              ),
                              color: ConstantsV2.orange.withOpacity(0.10),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                                child: Text("ver archivo"),
                              )
                          ),
                        ),
                      ),*/
                      const SizedBox(
                        height: 14,
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
