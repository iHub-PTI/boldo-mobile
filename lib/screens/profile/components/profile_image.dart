import 'package:dio/dio.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../../network/http.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({Key key}) : super(key: key);

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  String _profileImage;

  @override
  void initState() {
    _setProfileImage();
    super.initState();
  }

  Future<void> _setProfileImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString("profileImage");
    setState(() {
      _profileImage = prefs.getString("profileImage");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 128,
          width: 128,
          child: Card(
            child: _profileImage != null
                ? ClipOval(
                    child: Image.file(
                      File(_profileImage),
                      fit: BoxFit.cover,
                    ),
                  )
                : SvgPicture.asset(
                    'assets/images/DoctorImageMale.svg',
                  ),
            elevation: 4.0,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
          ),
        ),
        Positioned(
          top: 90,
          left: 90,
          child: GestureDetector(
            onTap: () async {
              try {
                FilePickerResult result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null) {
                  File croppedFile = await ImageCropper.cropImage(
                    sourcePath: result.files.first.path,
                    aspectRatioPresets: Platform.isAndroid
                        ? [
                            CropAspectRatioPreset.square,
                            CropAspectRatioPreset.ratio3x2,
                            CropAspectRatioPreset.original,
                            CropAspectRatioPreset.ratio4x3,
                            CropAspectRatioPreset.ratio16x9
                          ]
                        : [
                            CropAspectRatioPreset.original,
                            CropAspectRatioPreset.square,
                            CropAspectRatioPreset.ratio3x2,
                            CropAspectRatioPreset.ratio4x3,
                            CropAspectRatioPreset.ratio5x3,
                            CropAspectRatioPreset.ratio5x4,
                            CropAspectRatioPreset.ratio7x5,
                            CropAspectRatioPreset.ratio16x9
                          ],
                    androidUiSettings: const AndroidUiSettings(
                        toolbarTitle: 'Cropper',
                        toolbarColor: Colors.deepOrange,
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.original,
                        lockAspectRatio: false),
                    iosUiSettings: const IOSUiSettings(
                      title: 'Cropper',
                    ),
                  );

                  if (croppedFile != null) {
                    try {
                      // setState(() {
                      //   isLoading = true;
                      // });
                      // Response response = await dio.get("/presigned");
                      // print(response);

                      var documentDirectory =
                          await getApplicationDocumentsDirectory();
                      final String path = documentDirectory.path;

                      Random random = Random();
                      int randomNumber = random.nextInt(10000);
                      final File newImage =
                          await croppedFile.copy('$path/$randomNumber.jpg');
                      imageCache.clear();
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("profileImage", newImage.path);
                      //user.avatarLocalPath = newImage.path;
                      // user.avatar = response.data["key"];

                      // await http.put(response.data["url"],
                      //     body: croppedFile.readAsBytesSync());

                      // await dio.post("/user", data: {
                      //   "avatar": response.data["key"],
                      // });

                      setState(() {
                        _profileImage = newImage.path;
                      });
                    } catch (err) {
                      print(err);
                    }
                  }
                }
              } on PlatformException catch (e) {
                print("Unsupported operation" + e.toString());
              }
            },
            child: SizedBox(
              height: 32,
              width: 32,
              child: Card(
                margin: const EdgeInsets.all(0),
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/icon/camera.svg',
                  ),
                ),
                elevation: 4.0,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
              ),
            ),
          ),
        )
      ],
    );
  }
}
