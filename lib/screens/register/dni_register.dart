import 'dart:io';

import 'package:boldo/blocs/register_bloc/register_patient_bloc.dart';
import 'package:boldo/screens/take_picture/take_picture_screen.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path_package;
import 'package:path_provider/path_provider.dart';

import '../../constants.dart';
import '../../main.dart';

class DniRegister extends StatefulWidget {
  DniRegister({Key? key}) : super(key: key);

  @override
  State<DniRegister> createState() => _DniRegisterState();
}

class _DniRegisterState extends State<DniRegister> {
  ImagePicker picker = ImagePicker();
  var photoStage = UrlUploadType.frontal;
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
    final path = path_package.join(
        (await getTemporaryDirectory()).path,
        _isFrontDni ? 'front.png' : _selfieRequest ? 'selfie.png' : 'back.png');

    // Take a picture and save in path directory
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(cameras: cameras, path: path),
      ),
    );

    bool isExist = await File(path).exists();
    print("taked");
    if (isExist) {
      userImageSelected = XFile(path);
      BlocProvider.of<PatientRegisterBloc>(context).add(
          UploadPhoto(urlUploadType: photoStage, image: userImageSelected));
    } else {
      return;
    }
  }

  void getImageFromGallery() async {

    userImageSelected = await picker.pickImage(source: ImageSource.gallery,maxWidth: 500,maxHeight: 500, imageQuality: 50);

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

  bool _isFrontDni = true;
  bool _selfieRequest = false;
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
                      photoStage = state.actualPhotoStage;
                    });
                  }
                  if (state is Failed) {
                    emitSnackBar(
                        context: context,
                        text: state.response,
                        status: ActionStatus.Fail
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
                        return LoadingHelper();
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
                                  _selfieRequest ? Alignment.centerLeft : Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      _selfieRequest == true
                                          ? 'Por último, tomate una selfie.'
                                          : _isFrontDni
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
                                  _selfieRequest == true
                                      ? 'assets/images/selfie.png'
                                      : _isFrontDni
                                      ? 'assets/images/dni_front.png'
                                      : 'assets/images/dni_back.png',
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
                                      _selfieRequest == false
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