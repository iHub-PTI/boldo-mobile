import 'dart:io';

import 'package:boldo/main.dart';
import 'package:boldo/network/http.dart';
import 'package:boldo/screens/my_studies/bloc/my_studies_bloc.dart';
import 'package:boldo/screens/profile/components/profile_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../constants.dart';
import '../../models/DiagnosticReport.dart';

class AttachFiles extends StatefulWidget {
  DiagnosticReport diagnosticReport;
  AttachFiles({Key? key, required this.diagnosticReport}) : super(key: key);

  @override
  State<AttachFiles> createState() => _AttachFilesState();
}

class _AttachFilesState extends State<AttachFiles> {

  FilePickerResult? result;
  List<PlatformFile>? files;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstantsV2.lightGrey,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
          SvgPicture.asset('assets/Logo.svg', semanticsLabel: 'BOLDO Logo'),
        ),
      ),
      body: BlocListener<MyStudiesBloc, MyStudiesState>(
        listener: (context, state) {
          if (state is Loading) {
            print('loading');
          }
          if (state is Failed) {
            print('failed: ${state.msg}');
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text(state.msg)));
          }
        },
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
                'Atras',
                style: boldoHeadingTextStyle.copyWith(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            'Ajuntos',
                            style: boldoHeadingTextStyle.copyWith(fontSize: 20),
                          ),
                          Text(
                            "seleccioná los archivos o tomale fotos a los resultados de este estudio.",
                            style: boldoCorpSmallTextStyle.copyWith(color: ConstantsV2.inactiveText),
                          ),
                        ],
                      ),
                    )
                  ),
                  ProfileImageView2(height: 54, width: 54, border: true, patient: patient, color: ConstantsV2.orange,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
                child: Text(widget.diagnosticReport.description?? '',
                  style: boldoSubTextMediumStyle.copyWith(color: ConstantsV2.orange),

              ),
            ),
            result == null ? Expanded(
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
                              textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              primary: ConstantsV2.lightest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            onPressed: (){},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Tomar foto',
                                  style: boldoSubTextMediumStyle.copyWith(color: ConstantsV2.darkBlue),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                SvgPicture.asset('assets/icon/camera2.svg'),
                              ],
                            )
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              primary: ConstantsV2.lightest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            onPressed: () async {
                              result = await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                                type: FileType.custom,
                                allowedExtensions: ['jpg', 'pdf', 'jpeg', 'png'],
                              );
                              if(result!= null){
                                setState(() {
                                  files = result!.files;
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'seleccionar archivo',
                                  style: boldoSubTextMediumStyle.copyWith(color: ConstantsV2.darkBlue),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                SvgPicture.asset('assets/icon/attachment.svg'),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ) :
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: _fileElement,
                itemCount: files?.length ?? 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  result == null ? Container() :
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        primary: ConstantsV2.lightest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () async {
                        result = await FilePicker.platform.pickFiles(
                          allowMultiple: true,
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'pdf', 'jpeg', 'png'],
                        );
                        if(result!= null){
                          setState(() {
                            files = result?.files;
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/icon/post-add.svg'),
                        ],
                      )
                  ),
                  ElevatedButton (
                    onPressed: result != null ? () async {
                      try{
                        List<Map<String, dynamic>> attachmentUrls = [];
                        for(PlatformFile file in files!){
                          // TODO get url from server and put file
                          var value = {
                            "url": file.extension == 'pdf'
                                ? 'https://mipasaporte.boldo-dev.pti.org.py/healthPassport/vaccinationRegistry/d513dd8231a13a57637e8f6164e8abaa032fdd85109f83389ff54d44a3566357'
                                : file.extension == 'png'
                                ? 'https://0f9951f887.clvaw-cdnwnd.com/8c1735b21af00e5f1943a9959fa2230e/200000080-6e4576e458/ADSCRIPCI%C3%93N%20PEEC%20LABORATORIO%20A%C3%91O%202021.png?ph=0f9951f887'
                                : 'https://c8.alamy.com/compes/2c2thmn/formulario-de-laboratorio-para-rellenar-con-los-resultados-de-analisis-de-sangre-y-tubo-rojo-con-sangre-2c2thmn.jpg',
                            "contentType": file.extension == 'pdf' ? 'application/pdf': file.extension == 'png' ? 'image/png' : 'image/jpeg',
                          };
                          attachmentUrls.add(value);
                        }
                        Map<String, dynamic> diagnostic = widget.diagnosticReport.toJson();
                        diagnostic['attachmentUrls'] = attachmentUrls;
                        if(prefs.getBool(isFamily)?? false){
                          await dio.post('/profile/caretaker/dependent/${patient.id}/diagnosticReport', data: diagnostic);
                        }else{
                          await dio.post('/profile/patient/diagnosticReport', data: diagnostic);
                        }
                        Navigator.of(context).popUntil(ModalRoute.withName("/home"));
                      }on DioError catch(ex){
                        await Sentry.captureMessage(
                          ex.toString(),
                          params: [
                            {
                              "path": ex.requestOptions.path,
                              "data": ex.requestOptions.data,
                              "patient": patient.id,
                              "responseError": ex.response,
                            }
                          ],
                        );
                      }catch (exception, stackTrace){
                        await Sentry.captureException(
                          exception,
                          stackTrace: stackTrace,
                        );
                      }
                    }: null,
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

  Widget _fileElement(BuildContext context, int index){
    PlatformFile file = files![index];
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
                    SvgPicture.asset(
                        files![index].extension == 'pdf' ? 'assets/icon/picture-as-pdf.svg': 'assets/icon/crop-original.svg'
                    ),
                    Text(files![index].name,
                      style: boldoCorpMediumBlackTextStyle.copyWith(
                          color: ConstantsV2.activeText
                      ),
                    ),
                    GestureDetector(
                      onTap: (){

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
