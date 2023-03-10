import 'package:boldo/main.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/dashboard/tabs/components/empty_appointments_stateV2.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:boldo/screens/studies_orders/attach_study_by_order.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/header_page.dart';
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
  ServiceRequest? serviceRequest;
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
        actions: [],
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: SafeArea(
        child: Padding(
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

                  diagnosticReport.sort(((a, b) {
                    if (a.effectiveDate == null || b.effectiveDate == null) {
                      return 0;
                    }

                    try {
                      DateTime dateA =
                          DateTime.parse(a.effectiveDate as String);
                      DateTime dateB =
                          DateTime.parse(b.effectiveDate as String);

                      return dateB.compareTo(dateA);
                    } on FormatException catch (e) {
                      print(e.toString());
                      return 0;
                    }
                  }));
                });
              }

              if (state is Failed) {
                print('algo falló: ${state.msg}');
                _loading = false;
                _error = true;
                setState(() {});
                emitSnackBar(
                    context: context,
                    text: 'Falló la obtención de estudios',
                    status: ActionStatus.Fail
                );
              }

              if (state is ServiceRequestLoaded) {
                serviceRequest = state.serviceRequest;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AttachStudyByOrderScreen(
                            studyOrder: serviceRequest == null ? ServiceRequest() : serviceRequest!,
                          )));
              }
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 25,
                                color: Constants.extraColor400,
                              ),
                            ),
                            Expanded(
                              child: header("Mis Estudios", "Estudios"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  //   child: Row(
                  //     children: [
                  //       const Icon(
                  //         Icons.chevron_left_rounded,
                  //         size: 25,
                  //         color: Constants.extraColor400,
                  //       ),
                  //       Text(
                  //         'Estudios',
                  //         style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 10),
                  Text(
                    'En esta sección podés subir archivos y fotos de los resultados de tus estudios y los de tu familia.',
                    style: boldoHeadingTextStyle.copyWith(fontSize: 12),
                  ),
                  // const SizedBox(
                  //   height: 15,
                  // ),
                  // Text(
                  //   'Mis estudios',
                  //   style: boldoSubTextStyle.copyWith(
                  //       color: ConstantsV2.inactiveText),
                  // ),
                  const SizedBox(
                    height: 15,
                  ),
                  _loading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
                        backgroundColor: Constants.primaryColor600,
                      )
                    )
                    : diagnosticReport.isEmpty
                      ? const EmptyStateV2(
                        picture: "empty_studies.svg",
                        titleBottom: "Aún no tenés estudios",
                        textBottom:
                        "A medida en que uses la aplicación podrás ir viendo tus estudios",
                      )
                          : showDiagnosticList(),
                    ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          if(BlocProvider.of<MyStudiesBloc>(context).state is Loading){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Favor aguardar durante la carga."),
                backgroundColor: Colors.redAccent,
              ),
            );
          }else{
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => NewStudy()
                )
            );
          }
        },
        child: _loading
          ? const CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Constants.primaryColor400),
              backgroundColor: Constants.primaryColor600,
            )
          : Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'nuevo estudio',
                ),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset(
                  'assets/icon/upload.svg',
                ),
              ],
            )
          ),
      ),
    );
  }

  // showEmptyList() {
  //   return Center(
  //     child: Column(
  //       children: [
  //         if (_loading)
  //           const Text('Cargando...')
  //         else if (_error)
  //           const Text('Error')
  //         else ...[
  //           SvgPicture.asset('assets/images/empty_studies.svg',
  //               fit: BoxFit.cover),
  //           Text(
  //             'aún no tenés estudios para visualizar',
  //             textAlign: TextAlign.center,
  //             style: boldoSubTextStyle.copyWith(color: ConstantsV2.orange),
  //           ),
  //         ]
  //       ],
  //     ),
  //   );
  // }

  Widget showDiagnosticList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 200,
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
                      width: 40,
                      height: 40,
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
                                      (prefs.getString('userId') ?? '')
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
                                          diagnosticReport[index].source != null
                                              ? "subido por ${diagnosticReport[index].source?.split(' ')[0]}"
                                              : 'Boldo',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                        ]
                      ),
                      diagnosticReport[index].serviceRequestId != null
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              child: GestureDetector(
                                onTap: (){
                                  BlocProvider.of<MyStudiesBloc>(context)
                                        .add(GetServiceRequests(serviceRequestId: diagnosticReport[index]
                                                          .serviceRequestId!));
                                },
                                child: Card(
                                    margin: EdgeInsets.zero,
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5)),
                                    ),
                                    color: ConstantsV2.orange.withOpacity(0.10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                                      child: const Text("ver orden"),
                                    )),
                              ),
                            ),
                          ],
                        )
                        : Container()
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
