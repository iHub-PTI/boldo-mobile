import 'dart:io';

import 'package:boldo/blocs/attach_study_order_bloc/attachStudyOrder_bloc.dart';
import 'package:boldo/blocs/study_order_bloc/studyOrder_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/screens/dashboard/tabs/components/data_fetch_error.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart' as study_bloc;
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/photos_helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/image_visor.dart';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../models/DiagnosticReport.dart';

class AttachStudyByOrderScreen extends StatefulWidget {
  final ServiceRequest studyOrder;
  AttachStudyByOrderScreen({Key? key, required this.studyOrder}) : super(key: key);

  @override
  State<AttachStudyByOrderScreen> createState() => _AttachStudyByOrderScreenState();
}

class _AttachStudyByOrderScreenState extends State<AttachStudyByOrderScreen> {
  List<File> files = [];
  ServiceRequest? serviceRequest;
  String? notes;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AttachStudyOrderBloc>(context).add(GetStudyFromServer(serviceRequestId: widget.studyOrder.id ?? "0"));
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
        body: SafeArea(
          child: BlocListener<AttachStudyOrderBloc, AttachStudyOrderState>(
            listener: (context, state) {
              if (state is SendSuccess) {
                emitSnackBar(
                    context: context,
                    text: uploadedStudySuccessfullyMessage,
                    status: ActionStatus.Success
                );
                BlocProvider.of<StudyOrderBloc>(context)
                    .add(GetNewsId(encounter: widget.studyOrder.encounterId ?? "0"));
                Navigator.of(context)
                    .pop();
              }
              else if (state is FailedUploadFiles) {
                emitSnackBar(
                    context: context,
                    text: state.response,
                    status: ActionStatus.Fail
                );
              } else if (state is FailedLoadedStudies) {
                emitSnackBar(
                    context: context,
                    text: state.response,
                    status: ActionStatus.Fail
                );
              }if(state is StudyObtained){
                serviceRequest = state.serviceRequest;
                setState(() {

                });
              }
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  BackButtonLabel(
                    labelText: 'Detalles de la orden',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  child: Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        BlocBuilder<AttachStudyOrderBloc, AttachStudyOrderState>(
                                            builder: (context, state) {
                                              if(state is! LoadingStudies ){
                                                // show if not loading
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                                  child: Text(
                                                    "Número de orden: ${serviceRequest?.orderNumber?? 'Sin Nro de Orden'}",
                                                    style: bodyLargeBlack.copyWith(
                                                      color: ConstantsV2.orange,
                                                    ),
                                                  ),
                                                );
                                              }else{
                                                return Container();
                                              }
                                            }
                                        ),
                                        serviceRequest?.urgent ?? false
                                            ? Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          elevation: 0,
                                          color: ConstantsV2.orange ,
                                          margin: EdgeInsets.zero,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 6.0,
                                                top: 2.0,
                                                bottom: 2.0,
                                                right: 6.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icon/warning-white.svg',
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "urgente",
                                                  style:
                                                  boldoCorpSmallTextStyle.copyWith(
                                                      color: ConstantsV2.lightGrey),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ): Container(),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                child: Expanded(
                                  child: BlocBuilder<AttachStudyOrderBloc, AttachStudyOrderState>(
                                    builder: (context, state) {
                                      // in case of loading data
                                      if(state is LoadingStudies){
                                        return Text(
                                          'Cargando',
                                          style: boldoCorpSmallTextStyle.copyWith(
                                              color: ConstantsV2.inactiveText,
                                              fontSize: 14),
                                        );
                                      }else {
                                        // show if not loading
                                        return Text(
                                          serviceRequest?.diagnosis ??
                                              'Sin diagnóstico presuntivo',
                                          style: boldoCorpSmallTextStyle
                                              .copyWith(
                                              color: ConstantsV2.inactiveText,
                                              fontSize: 14),
                                        );
                                      }
                                    }
                                  )
                                )
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Text(
                                        "Emitido el",
                                        style: boldoCorpSmallSTextStyle.copyWith(
                                          color: ConstantsV2.inactiveText
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: BlocBuilder<AttachStudyOrderBloc, AttachStudyOrderState>(
                                          builder: (context, state) {
                                            // in case of loading data
                                            if(state is LoadingStudies){
                                              return Text(
                                                'Cargando',
                                                style: boldoSubTextMediumStyle.copyWith(
                                                    color: ConstantsV2.inactiveText
                                                ),
                                              );
                                            }else {
                                              // show if not loading
                                              return Text(
                                                '${formatDate(
                                                  DateTime.parse(serviceRequest?.authoredDate ??
                                                      DateTime.now().toString()),
                                                  [d, '/', m, '/', yyyy],
                                                )}',
                                                style: boldoSubTextMediumStyle.copyWith(
                                                    color: ConstantsV2.inactiveText
                                                ),
                                              );
                                            }
                                          }
                                      )
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                  BlocBuilder<AttachStudyOrderBloc, AttachStudyOrderState>(
                    builder: (context, state) {
                      // show only if not loading or failed
                      if(!(state is FailedLoadedStudies) && !(state is LoadingStudies)){
                        return Container(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                studiesDescription(),
                                filesDiagnosticReport(),
                                notesDiagnosticReport(),
                                serviceRequest?.diagnosticReports?.isEmpty?? true ?
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: BlocBuilder<AttachStudyOrderBloc, AttachStudyOrderState>(
                                    builder: (context, state) {
                                      // show only if not loading or failed
                                      if (state is UploadingStudy) {
                                        return Container(
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                  Constants.primaryColor400),
                                              backgroundColor: Constants.primaryColor600,
                                            )
                                          )
                                        );
                                      } else{
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: files.isNotEmpty
                                                  ? () async {
                                                DiagnosticReport diagnosticReport = DiagnosticReport(
                                                  effectiveDate: DateFormat('yyyy-MM-dd').format(DateTime(
                                                    DateTime.now().year,
                                                    DateTime.now().month,
                                                    DateTime.now().day,
                                                  )),
                                                  description: widget.studyOrder.description,
                                                  sourceID: patient.id,
                                                  patientNotes: notes,
                                                  type: changeCategory(widget.studyOrder.category),
                                                  serviceRequestId: widget.studyOrder.id,
                                                );
                                                BlocProvider.of<AttachStudyOrderBloc>(context).add(
                                                    SendStudyToServer(
                                                        diagnosticReport:
                                                        diagnosticReport,
                                                        files: files));
                                              }
                                                  : null,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Text('finalizar'),
                                                  const Padding(
                                                    padding: EdgeInsets.only(left: 8.0),
                                                    child: Icon(
                                                      Icons.chevron_right,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    }
                                  ),
                                ) : Container()
                              ],
                            ),
                          ),
                        );
                      }else if(state is LoadingStudies){
                        return Container(
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Constants.primaryColor400),
                              backgroundColor: Constants.primaryColor600,
                            )
                          )
                        );
                      }else if (state is FailedLoadedStudies) {
                        return Container(
                          child: DataFetchErrorWidget(
                            retryCallback: () =>
                              BlocProvider.of<AttachStudyOrderBloc>(context).add(
                                GetStudyFromServer(
                                  serviceRequestId: widget.studyOrder.id ?? "0"
                                )
                              )
                          )
                        );
                      }else {
                        return Container();
                      }
                    }
                  ),

                ],
              ),
            ),
          ),
        ));
  }

  showEmptyList() {
    return Column(
      children: [
        SvgPicture.asset('assets/images/empty_studies.svg', fit: BoxFit.cover),
        Text('Aun no tenés estudios para visualizar')
      ],
    );
  }

  Widget filesDiagnosticReport(){
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icon/paper-clip.svg'),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Adjuntos',
                        style: boldoSubTextStyle.copyWith(
                            color: ConstantsV2.activeText),
                      ),
                    ],
                  ),
                ),
                serviceRequest?.diagnosticReports?.isEmpty?? true ? Container(
                  child: _offsetPopup(),
                ) : Container(),
              ],
            ),
          ),
          serviceRequest?.diagnosticReports?.isEmpty?? true ? Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: ConstantsV2.lightest,
            child: files.isEmpty ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: _offsetPopup(
                child: Text(
                  'adjuntar un archivo',
                  style: boldoSubTextMediumStyle.copyWith(decoration: TextDecoration.underline,),
                ),
              ),
            ): ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: _fileElement,
              itemCount: files.length,
              physics: const ClampingScrollPhysics(),
            ),
          ) : ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: _fileServerElement,
            itemCount: serviceRequest?.diagnosticReports?.length,
            physics: const ClampingScrollPhysics(),
          ),
        ],
      ),
    );
  }

  Widget studiesDescription(){
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Text(
                        'Estudios',
                        style: boldoSubTextStyle.copyWith(
                            color: ConstantsV2.activeText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: ConstantsV2.lightest,
            child: serviceRequest?.studiesCodes?.isEmpty?? true ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Container(
                child: GestureDetector(
                  onTap: () async {
                    _noteBox(notes);
                  },
                  child: Row(
                    children: [
                      Text(
                        'Sin descripción de la orden',
                        style: boldoSubTextMediumStyle.copyWith(decoration: TextDecoration.underline,),
                      ),
                    ],
                  ),
                ),
              ),
            ): ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return showStudyDescription(context, index, serviceRequest?.studiesCodes?[index]?? StudiesCodes());
              },
              itemCount: serviceRequest?.studiesCodes?.length,
              physics: const ClampingScrollPhysics(),
            ),
          )
        ],
      ),
    );
  }

  Widget notesDiagnosticReport(){
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Text(
                        'Comentario',
                        style: boldoSubTextStyle.copyWith(
                            color: ConstantsV2.activeText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          serviceRequest?.diagnosticReports?.isEmpty?? true ? Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: ConstantsV2.lightest,
            child: notes?.isEmpty?? true ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Container(
                child: GestureDetector(
                  onTap: () async {
                    await _noteBox(notes);
                    setState(() {

                    });
                    },
                  child: Row(
                    children: [
                      Text(
                        'agregar un comentario',
                        style: boldoSubTextMediumStyle.copyWith(decoration: TextDecoration.underline,),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      SvgPicture.asset('assets/icon/pencil-alt.svg'),
                    ],
                  ),
                ),
              ),
            ): Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  color: ConstantsV2.lightest,
                  child: Text("$notes"),
                ),
                GestureDetector(
                  onTap: () async {
                    await _noteBox(notes);
                    setState(() {

                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Text(
                          'editar comentario',
                          style: boldoSubTextMediumStyle.copyWith(decoration: TextDecoration.underline,),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        SvgPicture.asset('assets/icon/pencil-alt.svg'),
                      ],
                    ),
                  )
                ),
              ],
            )
          ) : ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: _notesServerElement,
            itemCount: serviceRequest?.diagnosticReports?.length,
            physics: const ClampingScrollPhysics(),
          ),
        ],
      ),
    );
  }

  getFromCamera() async {
    XFile? image;
    image = await ImagePicker.platform
        .getImage(source: ImageSource.camera);
    if(image != null) {
      File? x = await cropPhoto(file: image);
      if (x != null) {
        setState(() {
          if (files.isNotEmpty) {
            files = [...files, File(x.path)];
          } else {
            files = [File(x.path)];
          }
        });
      }
    }
  }

  getFromFiles() async {
    FilePickerResult? result;
    result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        if (files.isNotEmpty) {
          files = [
            ...files,
            ...result!.files.map((e) => File(e.path!)).toList()
          ];
        } else {
          files = result!.files.map((e) => File(e.path!)).toList();
        }
      });
    }
  }

  getFromGallery() async {
    XFile? image;
    image = await ImagePicker.platform
        .getImage(source: ImageSource.gallery);
    if(image != null) {
      File? x = await cropPhoto(file: image);
      if (x != null) {
        setState(() {
          if (files.isNotEmpty) {
            files = [...files, File(x.path)];
          } else {
            files = [File(x.path)];
          }
        });
      }
    }
  }

  Widget _offsetPopup({Widget? child}) {
    return PopupMenuButton<int>(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                onTap: getFromCamera,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset('assets/icon/camera2.svg'),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'tomar foto',
                      style: boldoSubTextMediumStyle.copyWith(
                          color: ConstantsV2.darkBlue),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                onTap: getFromFiles,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset('assets/icon/attachment.svg'),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'seleccionar archivo',
                      style: boldoSubTextMediumStyle.copyWith(
                          color: ConstantsV2.darkBlue),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 4,
                onTap: getFromGallery,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset('assets/icon/image-search.svg'),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'seleccionar imagen',
                      style: boldoSubTextMediumStyle.copyWith(
                          color: ConstantsV2.darkBlue),
                    ),
                  ],
                ),
              ),
            ],
        child: child?? Card(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset('assets/icon/add-outline.svg'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: ConstantsV2.orange.withOpacity(0.8),
        ),
    );
  }

  Widget _fileServerElement(BuildContext context, int index){
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index2) {
                return showStudy(context, index2, serviceRequest?.diagnosticReports?[index]?? DiagnosticReport());
                },
              itemCount: serviceRequest?.diagnosticReports?[index].attachmentUrls?.length,
              physics: const ClampingScrollPhysics(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _notesServerElement(BuildContext context, int index){
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 4),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: ConstantsV2.lightest,
            child: Container(
              child: Text("${ (serviceRequest?.diagnosticReports?.length?? 0) > 1 ?"Notas del estudio ${index + 1} (${serviceRequest?.diagnosticReports?[index].effectiveDate?? "Sin fecha"} ):" : ''}  ${serviceRequest?.diagnosticReports?[index].patientNotes?? "Sin notas"}"),
            ),
          ),
        ),
      ],
    );
  }

  Future _noteBox(String? notes){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          String? note = notes;
          return StatefulBuilder(
            builder: (context, setState){
              return AlertDialog(
                contentPadding: const EdgeInsetsDirectional.all(0),
                scrollable: true,
                backgroundColor: ConstantsV2.lightest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery
                        .of(context)
                        .size
                        .height * 0.5,
                    maxWidth: MediaQuery
                        .of(context)
                        .size
                        .width * 0.5,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            initialValue: notes,
                            keyboardType: TextInputType.multiline,
                            expands: true,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintMaxLines: 10,
                              hintText: "Ingrese un comentario sobre el estudio",
                              fillColor: ConstantsV2.lightAndClear,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            style: boldoCorpMediumTextStyle.copyWith(
                                color: ConstantsV2.activeText
                            ),
                            onChanged: (value) {
                              setState(() {
                                note = value.trimRight().trimLeft();
                              });
                            },
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                              },
                              child: Card(
                                  margin: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16)),
                                  ),
                                  color: ConstantsV2.orange.withOpacity(0.10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 7),
                                    child: const Text("cancelar"),
                                  )
                              ),
                            ),
                          ),
                          Container(
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  this.notes = note?.trimRight().trimLeft();
                                  Navigator.pop(context);
                                });
                              },
                              child: Card(
                                  margin: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16)),
                                  ),
                                  color: ConstantsV2.orange.withOpacity(0.10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 7),
                                    child: const Text("guardar"),
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          );
        },
    );
  }

  Widget _fileElement(BuildContext context, int index) {
    File file = files[index];
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
            OpenFilex.open(file.path)
            ,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Row(
                            children: [
                              SvgPicture.asset(p.extension(file.path).toLowerCase() == '.pdf'
                                  ? 'assets/icon/picture-as-pdf.svg'
                                  : 'assets/icon/crop-original.svg'),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          p.basename(
                                            file.path,
                                          ),
                                          style: boldoCorpMediumBlackTextStyle.copyWith(
                                              color: ConstantsV2.activeText,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      SvgPicture.asset('assets/icon/chevron-right.svg'),
                                    ],
                                  )
                              ),
                            ],
                          )
                      ),
                      GestureDetector(
                        onTap: () {
                          files.remove(file);
                          setState(() {});
                        },
                        child: SvgPicture.asset(
                          'assets/icon/trash.svg',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget showStudy(BuildContext context, int index, DiagnosticReport diagnosticReport) {
    String type = getTypeFromContentType(
        diagnosticReport.attachmentUrls?[index].contentType) ??
        '';
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          if (type == 'jpeg' || type == 'png') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ImageVisor(
                    url: diagnosticReport.attachmentUrls![index].url?? '',
                  )),
            );
          } else if (type == 'pdf') {
            BlocProvider.of<study_bloc.MyStudiesBloc>(context).add(study_bloc.GetUserPdfFromUrl(
                url: diagnosticReport.attachmentUrls![index].url));
          }
        },
        child: Container(
          padding: const EdgeInsets.only(top: 8, left: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: ClipOval(
                  child: SizedBox(
                    width: 54,
                    height: 54,
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
                                "${diagnosticReport.attachmentUrls![index].title}",
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

  Widget showStudyDescription(BuildContext context, int index, StudiesCodes studiesCodes) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          Row(
            children: [
              // the orange circle
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 2,
                  width: 2,
                  decoration: const BoxDecoration(
                      color: ConstantsV2.activeText, shape: BoxShape.circle),
                ),
              ),
              Text(
                studiesCodes.display?? '',
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: ConstantsV2.inactiveText),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  studiesCodes.note?? '',
                  style: boldoCorpMediumTextStyle.copyWith(color: ConstantsV2.inactiveText)
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      )
    );
  }

  String? changeCategory(String? type){
    if(type == 'Laboratory'){
      return 'LABORATORY';
    }else if(type == 'Diagnostic Imaging'){
      return 'IMAGE';
    }else{
      return 'OTHER';
    }
  }

}
