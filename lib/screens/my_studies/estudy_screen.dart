import 'package:boldo/main.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/image_visor.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../../constants.dart';
import '../../models/DiagnosticReport.dart';

class Study extends StatefulWidget {
  final String id;
  Study({Key? key, required this.id}) : super(key: key);

  @override
  State<Study> createState() => _StudyState();
}

class _StudyState extends State<Study> {
  bool _loading = true;
  bool _error = false;
  DiagnosticReport? diagnosticReport;
  @override
  void initState() {
    BlocProvider.of<MyStudiesBloc>(context)
        .add(GetPatientStudyFromServer(id: widget.id));
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
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: BlocListener<MyStudiesBloc, MyStudiesState>(
            listener: (context, state) {
              if (state is Loading) {
                _loading = true;
                _error = false;
                print('loading');
                setState(() {});
              }
              if (state is DiagnosticStudyLoaded) {
                print('success DiagnosticLoaded');
                _loading = false;
                _error = false;
                setState(() {
                  diagnosticReport = state.study;
                });
              }
              if (state is Success) {
                print('success DiagnosticLoaded');
                _loading = false;
                _error = false;
                setState(() {});
              }

              if (state is Failed) {
                print('algo falló: ${state.msg}');
                _loading = false;
                _error = true;
                setState(() {});
                emitSnackBar(
                    context: context,
                    text: "Falló la obtención de estudios",
                    status: ActionStatus.Fail
                );
              }
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackButtonLabel(
                    labelText: 'Detalles del estudio',
                  ),
                  if (_loading)
                    Container(
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Constants.primaryColor400),
                          backgroundColor: Constants.primaryColor600,
                        ),
                      ),
                    ),
                  if (_error)
                    DataFetchErrorWidget(
                        retryCallback: () =>
                            BlocProvider.of<MyStudiesBloc>(context)
                                .add(GetPatientStudyFromServer(id: widget.id))),
                  if (!_loading && !_error)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              child: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${diagnosticReport?.description}",
                                  style: boldoTitleBlackTextStyle.copyWith(
                                      color: ConstantsV2.activeText),
                                ),
                              ],
                            ),
                          )),
                          ImageViewTypeForm(
                            height: 54,
                            width: 54,
                            border: true,
                            url: patient.photoUrl,
                            gender: patient.gender,
                            borderColor: ConstantsV2.orange,
                          ),
                        ],
                      ),
                    ),
                  if (!_loading && !_error)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'fuente',
                                style: boldoCorpSmallInterTextStyle.copyWith(
                                    color: ConstantsV2.activeText),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Card(
                                  margin: EdgeInsets.zero,
                                  elevation: 0,
                                  color: ConstantsV2.lightest,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(0),
                                    child: sourceLogo(diagnosticReport?.source
                                        ?.toUpperCase(), diagnosticReport?.sourceID),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'fecha de realización',
                                style: boldoCorpSmallInterTextStyle.copyWith(
                                    color: ConstantsV2.activeText),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Text(
                                  "${DateFormat('dd/MM/yy').format(DateTime.parse(diagnosticReport?.effectiveDate ?? "2000-01-01").toLocal())}",
                                  style: boldoSubTextMediumStyle.copyWith(
                                      color: ConstantsV2.activeText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 15,
                  ),
                  diagnosticReport == null
                      ? showEmptyList()
                      : showDiagnosticList()
                ],
              ),
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
          const Center(child: Text('Cargando...'))
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adjuntos',
          style: boldoSubTextStyle.copyWith(color: ConstantsV2.activeText),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          child: ListView.builder(
            itemCount: diagnosticReport?.attachmentUrls?.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: showStudy,
          ),
        ),
      ],
    );
  }

  Widget showStudy(BuildContext context, int index) {
    String type = getTypeFromContentType(
            diagnosticReport?.attachmentUrls?[index].contentType) ??
        '';
    return InkWell(
      onTap: () {
        if (type == 'jpeg' || type == 'png') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageVisor(
                  url: diagnosticReport!.attachmentUrls![index].url?? '',
                )),
          );
        } else if (type == 'pdf') {
          BlocProvider.of<MyStudiesBloc>(context).add(GetUserPdfFromUrl(
              url: diagnosticReport!.attachmentUrls![index].url));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            shadowAttachStudy,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                children: [
                  Container(
                    child: SvgPicture.asset(
                      type == 'pdf'
                          ? 'assets/icon/picture-as-pdf.svg'
                          : (type == 'jpeg' || type == 'png')
                              ? 'assets/icon/crop-original.svg'
                              : 'assets/Logo.svg',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Flex(
                          mainAxisSize: MainAxisSize.min,
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              child: Text(
                                "${diagnosticReport!.attachmentUrls![index].title}",
                                style: boldoCorpMediumBlackTextStyle.copyWith(
                                    color: ConstantsV2.activeText),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sourceLogo (String? source, String? sourceID){
    return Image.asset(
      source == null?
        'assets/images/Source=No_source.png':
      source == 'VENTRIX'
          ? 'assets/images/Source=Ventrix.png':
      source == 'TESÂI'
          ? 'assets/images/Source=Tesai.png':
          'assets/images/Source=Paciente.png',
    );
  }

}
