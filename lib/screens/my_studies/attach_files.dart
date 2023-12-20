import 'dart:io';

import 'package:boldo/blocs/new_study_bloc/new_study_bloc.dart';
import 'package:boldo/main.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart' as studies_bloc;
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/photos_helpers.dart';
import 'package:boldo/widgets/back_button.dart';
import 'package:boldo/widgets/file_locale.dart';
import 'package:boldo/widgets/loading.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';
import '../../models/DiagnosticReport.dart';

class AttachFiles extends StatefulWidget {
  final DiagnosticReport diagnosticReport;
  final NewStudyBloc newStudyBloc;
  AttachFiles({
    Key? key,
    required this.diagnosticReport,
    required this.newStudyBloc,
  }) : super(key: key);

  @override
  State<AttachFiles> createState() => _AttachFilesState();
}

class _AttachFilesState extends State<AttachFiles> {

  @override
  void initState() {
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
            child: SvgPicture.asset('assets/Logo.svg',
                semanticsLabel: 'BOLDO Logo'),
          ),
        ),
        body: SafeArea(
          child: BlocListener<NewStudyBloc, NewStudyState>(
            bloc: widget.newStudyBloc,
            listener: (context, state) {
              if (state is Uploaded) {
                emitSnackBar(
                    context: context,
                    text: uploadedStudySuccessfullyMessage,
                    status: ActionStatus.Success
                );
                Navigator.of(context)
                    .popUntil(ModalRoute.withName("/my_studies"));
                BlocProvider.of<studies_bloc.MyStudiesBloc>(context)
                    .add(studies_bloc.GetPatientStudiesFromServer());
              }
              if (state is FailedUpload) {
                print('failed: ${state.msg}');
                emitSnackBar(
                    context: context,
                    text: state.msg,
                    status: ActionStatus.Fail
                );
              }
              if(state is FilesObtained){
                files = state.files;
                setState(() {

                });
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                BackButtonLabel(
                  labelText: 'Adjuntos',
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
                            Text(
                              "Seleccioná los archivos o tomale fotos a los resultados de este estudio.",
                              style: boldoCorpSmallTextStyle.copyWith(
                                  color: ConstantsV2.inactiveText,
                                  fontSize: 14),
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.diagnosticReport.description ?? '',
                    style: boldoSubTextMediumStyle.copyWith(
                        color: ConstantsV2.orange),
                  ),
                ),
                widget.newStudyBloc.files.isEmpty
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Container(
                            child: Center(
                              child: Container(
                                width: 216,
                                child: ListView(
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
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemBuilder: _fileElement,
                          itemCount: widget.newStudyBloc.files.length,
                          separatorBuilder: (_,index) {
                            return const SizedBox(
                              height: 4,
                            );
                          },
                        ),
                      ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.newStudyBloc.files.isEmpty
                          ? Container()
                          : Container(
                              child: _offsetPopup(),
                            ),
                      BlocBuilder<NewStudyBloc, NewStudyState>(
                        bloc: widget.newStudyBloc,
                        builder: (BuildContext context, state){

                          Widget child;
                          if(state is Uploading){
                            child = loadingStatus();
                          }else{
                            child = const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('finalizar'),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.chevron_right,
                                  ),
                                ),
                              ],
                            );
                          }
                          return ElevatedButton(
                            onPressed: widget.newStudyBloc.files.isNotEmpty && !(state is Uploading)
                                ? () async {
                              widget.newStudyBloc.add(
                                  SendStudyToServer(
                                      diagnosticReport:
                                      widget.diagnosticReport,
                                      files: widget.newStudyBloc.files));
                            }
                                : null,
                            child: child,
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
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

  getFromCamera() async {
    XFile? image;
    image = await pickImage(
        context: context,
        source: ImageSource.camera,
        permissionDescription: 'Se requiere acceso para tomar fotos'
    );
    if(image != null) {
      File? x = await cropPhoto(file: image);
      if (x != null) {
        widget.newStudyBloc.addFiles(

            newFiles: [File(x.path)]

        ).then((value) =>
            setState(() {

            })
        );
      }
    }
  }

  getFromFiles() async {
    FilePickerResult? result;
    result = await pickFiles(
      context: context,
      withData: true,
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'jpeg', 'png'],
    );
    if (result != null) {
      widget.newStudyBloc.addFiles(

          newFiles: result!.files.map((e) => File(e.path!)).toList()

      ).then((value) => setState((){

      })
      );

    }
  }

  getFromGallery() async {
    XFile? image;
    image = await pickImage(
        context: context,
        source: ImageSource.gallery,
        permissionDescription: 'Se requiere acceso para subir fotos de la galeria');
    if(image != null) {
      File? x = await cropPhoto(file: image);
      if (x != null) {
        widget.newStudyBloc.addFiles(

            newFiles: [File(x.path)]

        ).then((value) => setState((){

        })
        );

      }
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
    File file = widget.newStudyBloc.files[index].key;

    String? _errorMessage;
    if(widget.newStudyBloc.files[index].value.isLeft()){
      widget.newStudyBloc.files[index].value.leftMap((l) => _errorMessage=  l.message);
    }


    return FileLocaleCard(
      file: file,
      deleteAction: (){
        widget.newStudyBloc.removeFiles(

            filesToRemove: [file]

        ).then((value) => setState((){

        })
        );
      },
      errorMessage: _errorMessage,
    );
  }
}
