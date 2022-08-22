import 'dart:io';

import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/screens/take_picture/take_picture_screen.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path_package;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../constants.dart';
import '../../../main.dart';

class DniFamilyRegister extends StatefulWidget {
  DniFamilyRegister({Key? key}) : super(key: key);

  @override
  State<DniFamilyRegister> createState() => _DniFamilyRegisterState();
}

class _DniFamilyRegisterState extends State<DniFamilyRegister> {
  ImagePicker picker = ImagePicker();
  late var cameras;
  late var firstCamera;
  @override
  void initState(){
    super.initState();
    initializedCamera();
  }

  @override
  void dispose() {
    photoStage = UrlUploadType.frontal;
    super.dispose();
  }

  void getImageFromCamera() async {
    userImageSelected = await pickImage(
        context: context,
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 50,
        permissionDescription: 'Se requiere acceso para tomar fotos'
    );
    if (userImageSelected != null) {
      BlocProvider.of<PatientRegisterBloc>(context).add(
          UploadPhoto(urlUploadType: photoStage, image: userImageSelected));
    } else {
      return;
    }
  }

  void getImageFromGallery() async {

    userImageSelected = await pickImage(
        context: context,
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 50,
        permissionDescription: 'Se requiere acceso para seleccionar una foto'
    );
    if (userImageSelected != null) {
      BlocProvider.of<PatientRegisterBloc>(context).add(
          UploadPhoto(urlUploadType: photoStage, image: userImageSelected));
    } else {
      return;
    }
  }

  void initializedCamera() async {
    cameras = await availableCameras();
    firstCamera = cameras[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration( // Background linear gradient
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[
                          ConstantsV2.primaryColor100,
                          ConstantsV2.primaryColor200,
                          ConstantsV2.primaryColor300,
                        ],
                        stops: <double>[
                          ConstantsV2.primaryStop100,
                          ConstantsV2.primaryStop200,
                          ConstantsV2.primaryStop300,
                        ]
                    )
                ),
              ),
              Opacity(
                opacity: 0.2,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                            'assets/images/register_background.png')
                    ),
                  ),
                ),
              ),
              BlocListener(
                bloc: BlocProvider.of<PatientRegisterBloc>(context),
                listener: (context, state) {
                  if (state is SuccessPhotoUploaded) {
                    setState(() {
                    });
                  }
                  if (state is Failed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.response!),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                  if (state is NavigateNextScreen) {
                    Navigator.pushNamed(context, state.routeName);
                  }
                  if (state is NavigateNextAndDeleteUntilScreen) {
                    Navigator.of(context).pushNamedAndRemoveUntil(state.routeName, ModalRoute.withName(state.untilName) );
                  }
                },
                child: BlocBuilder(
                  bloc: BlocProvider.of<PatientRegisterBloc>(context),
                  builder: (context, state) {
                  if (state is Success) {
                    return SuccesLoaded();
                  }
                  if (state is Loading) {
                    return const LoadingHelper();
                  }
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(top: 60.0),
                                  child: SvgPicture.asset(
                                    'assets/icon/logo_text.svg',
                                    height: 100,
                                    width: 100,
                                  )),
                              const SizedBox(
                                height: 40,
                              ),
                              Text(
                                'verificá tu identidad',
                                textAlign: TextAlign.center,
                                style: boldoSubTextStyle.copyWith(fontSize: 25),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment:
                                photoStage == UrlUploadType.selfie ? Alignment.centerLeft : Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    photoStage == UrlUploadType.selfie
                                        ? 'Por último, tomate una selfie.'
                                        : photoStage == UrlUploadType.frontal
                                        ? 'A continuación, subí una foto de la cara frontal de tu cédula de identidad paraguaya.'
                                        : 'Genial! Ahora una foto de la cara posterior de tu cédula de identidad paraguaya.',
                                    style: boldoSubTextStyle.copyWith(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('¿por qué me solicitan esta información?',
                                  style: TextStyle(
                                      fontSize: 16,
                                      decoration: TextDecoration.underline,
                                      color: ConstantsV2.focuseBorder)),
                              const SizedBox(
                                height: 20,
                              ),
                              Image.asset(
                                photoStage == UrlUploadType.selfie
                                    ? 'assets/images/selfie.png'
                                    : photoStage == UrlUploadType.frontal
                                    ? 'assets/images/CI_Illustration.png'
                                    : 'assets/images/CI_Illustration_back.png',
                                height: 250,
                                width: MediaQuery.of(context).size.width,
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    photoStage != UrlUploadType.selfie
                                        ? Padding(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      child: OutlinedButton(
                                          child: Row(
                                              children: [
                                                const Text("archivo"),
                                                SvgPicture.asset('assets/icon/photo-library.svg'),
                                              ]
                                          ),
                                          onPressed: () async {
                                            getImageFromGallery();
                                          }),
                                    )
                                        : Container(),
                                    ElevatedButton(
                                      child: Row(
                                          children: [
                                            const Text("camara"),
                                            SvgPicture.asset('assets/icon/camera.svg'),
                                          ]
                                      ),
                                      onPressed: () async {
                                        getImageFromCamera();
                                      },
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
                ),
              )
            ]
        )
    );
  }
}