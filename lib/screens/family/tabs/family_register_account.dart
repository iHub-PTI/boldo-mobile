import 'dart:io';

import 'package:boldo/provider/auth_provider.dart';
import 'package:boldo/screens/sing_in/sing_in_transition.dart';
import 'package:boldo/screens/take_picture/take_picture_screen.dart';
import 'package:boldo/utils/authenticate_user_helper.dart';
import 'package:boldo/utils/loading_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import 'defined_relationship_screen.dart';
import 'familyConnectTransition.dart';

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

  void initializedCamera() async {
    cameras = await availableCameras();
    firstCamera = cameras[0];
  }

  var _image;
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
              Align(
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
                                      XFile? image = await picker.pickImage(
                                          source: ImageSource.gallery);
                                      if (image != null) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LoadingHelper(
                                                image: File(image.path),
                                              )),
                                        );
                                        setState(() {
                                          if (_isFrontDni == true) {
                                            _isFrontDni = false;
                                          } else {
                                            _selfieRequest = true;
                                          }
                                        });
                                      }
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
                                  try {
                                    final path = join(
                                        (await getTemporaryDirectory()).path,
                                        _isFrontDni ? 'front.png' : _selfieRequest ? 'selfie.png' : 'back.png');
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TakePictureScreen(cameras: cameras, path: path),
                                      ),
                                    );
                                    bool isExist = await File(path).exists();
                                    if ( isExist ) {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoadingHelper(
                                              image: File(path),
                                            )
                                        ),
                                      );
                                      File(path).delete();
                                      imageCache!.clearLiveImages();
                                      imageCache!.clear();
                                      if(_selfieRequest){
                                        print(Provider.of<AuthProvider>(context, listen: false).getAuthenticated);
                                        if(!Provider.of<AuthProvider>(context, listen: false).getAuthenticated)
                                          Navigator.of(context).pushNamedAndRemoveUntil('/login', ModalRoute.withName('/onboarding') );
                                        else {
                                          Provider.of<AuthProvider>(context, listen: false).setIsFamily(isFamily: true);
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FamilyConnectTransition(
                                                )
                                            ),
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DefinedRelationshipScreen()
                                            ),
                                          );
                                        }
                                      }
                                      setState(() {
                                        if (_isFrontDni == true) {
                                          _isFrontDni = false;
                                        } else {
                                          _selfieRequest = true;
                                        }
                                      });
                                    }
                                  }catch(e){
                                    print("Image error $e");
                                  }

                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]
        )
    );
  }
}