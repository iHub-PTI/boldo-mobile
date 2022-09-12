import 'dart:io';

import 'package:boldo/blocs/attach_study_order_bloc/attachStudyOrder_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../models/DiagnosticReport.dart';

class AttachStudyByOrderScreen extends StatefulWidget {
  final StudyOrder studyOrder;
  AttachStudyByOrderScreen({Key? key, required this.studyOrder}) : super(key: key);

  @override
  State<AttachStudyByOrderScreen> createState() => _AttachStudyByOrderScreenState();
}

class _AttachStudyByOrderScreenState extends State<AttachStudyByOrderScreen> {
  List<File> files = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AttachStudyOrderBloc(),
      child: Scaffold(
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Estudio subido!"),
                      backgroundColor: ConstantsV2.green,
                    ),
                  );
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName("/my_studies"));
                }
                if (state is FailedUploadFiles) {
                  print('failed: ${state.response}');
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(state.response)));
                }
                // TODO : get files if you have previously uploaded files
                /*if(state is FilesObtained){
                  files = state.files;
                  setState(() {

                  });
                }*/
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
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
                      'Detalles de la orden',
                      style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            child: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widget.studyOrder.urgent?? false
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
                                  Text(
                                    widget.studyOrder.diagnosis?? 'Sin diagnostico presuntivo',
                                    style: boldoCorpSmallTextStyle.copyWith(
                                        color: ConstantsV2.inactiveText,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            )),
                        ProfileImageView2(
                          height: 54,
                          width: 54,
                          border: true,
                          patient: patient,
                          color: ConstantsV2.orange,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.studyOrder.diagnosis ?? '',
                      style: boldoSubTextMediumStyle.copyWith(
                          color: ConstantsV2.orange),
                    ),
                  ),
                  files.isEmpty
                      ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        child: Center(
                          child: Container(
                            width: 216,
                            child: Column(
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 16),
                                      primary: ConstantsV2.lightest,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(100),
                                      ),
                                    ),
                                    onPressed: getFromCamera,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Tomar foto',
                                          style: boldoSubTextMediumStyle
                                              .copyWith(
                                              color:
                                              ConstantsV2.darkBlue),
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        SvgPicture.asset(
                                            'assets/icon/camera2.svg'),
                                      ],
                                    )),
                                const SizedBox(
                                  height: 16,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 16),
                                    primary: ConstantsV2.lightest,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(100),
                                    ),
                                  ),
                                  onPressed: getFromFiles,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'seleccionar archivo',
                                        style: boldoSubTextMediumStyle
                                            .copyWith(
                                            color:
                                            ConstantsV2.darkBlue),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      SvgPicture.asset(
                                          'assets/icon/attachment.svg'),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 16),
                                    primary: ConstantsV2.lightest,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(100),
                                    ),
                                  ),
                                  onPressed: getFromGallery,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'seleccionar imagen',
                                        style: boldoSubTextMediumStyle
                                            .copyWith(
                                            color:
                                            ConstantsV2.darkBlue),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      SvgPicture.asset(
                                          'assets/icon/image-search.svg'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      : Expanded(
                    child: BlocBuilder<AttachStudyOrderBloc, AttachStudyOrderState>(
                      builder: (context, state) {
                        if (state is UploadingStudy) {
                          return Container(
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Constants.primaryColor400),
                                backgroundColor: Constants.primaryColor600,
                              ),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: _fileElement,
                            itemCount: files.length,
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        files.isEmpty
                            ? Container()
                            : Container(
                          child: _offsetPopup(),
                        ),
                        ElevatedButton(
                          onPressed: files.isNotEmpty
                              ? () async {
                            DiagnosticReport diagnosticReport = DiagnosticReport(
                              effectiveDate: DateTime.now().toIso8601String(),
                              sourceID: patient.id,
                              type: widget.studyOrder.category,
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
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  showEmptyList() {
    return Column(
      children: [
        SvgPicture.asset('assets/images/empty_studies.svg', fit: BoxFit.cover),
        Text('Aun no tenés estudios para visualizar')
      ],
    );
  }

  getFromCamera() async {
    XFile? x;
    x = await ImagePicker.platform
        .getImage(source: ImageSource.camera);
    if (x != null) {
      setState(() {
        if (files.isNotEmpty) {
          files = [...files, File(x!.path)];
        } else {
          files = [File(x!.path)];
        }
      });
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
    XFile? x;
    x = await ImagePicker.platform
        .getImage(source: ImageSource.gallery);
    if (x != null) {
      setState(() {
        if (files.isNotEmpty) {
          files = [...files, File(x!.path)];
        } else {
          files = [File(x!.path)];
        }
      });
    }
  }

  Widget _offsetPopup() {
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
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: const BorderSide(
                  color: ConstantsV2.orange,
                  width: 1,
                )),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/icon/post-add.svg'),
                ],
              ),
            )));
  }

  Widget _fileElement(BuildContext context, int index) {
    File file = files[index];
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(p.extension(file.path).toLowerCase() == '.pdf'
                        ? 'assets/icon/picture-as-pdf.svg'
                        : 'assets/icon/crop-original.svg'),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        p.basename(
                          file.path,
                        ),
                        style: boldoCorpMediumBlackTextStyle.copyWith(
                            color: ConstantsV2.activeText,
                            overflow: TextOverflow.ellipsis),
                      ),
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
      ],
    );
  }
}
