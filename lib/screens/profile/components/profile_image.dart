import 'package:boldo/constants.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../provider/user_provider.dart';
import '../../../network/http.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({Key key}) : super(key: key);

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 128,
          width: 128,
          child: Card(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(26.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor400),
                      backgroundColor: Constants.primaryColor600,
                    ),
                  )
                : ClipOval(
                    child: Selector<UserProvider, String>(
                      builder: (_, gender, __) {
                        return Selector<UserProvider, String>(
                          builder: (_, data, __) {
                            if (data == null) {
                              return SvgPicture.asset(
                                gender != null && gender == "female"
                                    ? 'assets/images/femalePatient.svg'
                                    : 'assets/images/malePatient.svg',
                              );
                            }
                            return CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: data,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Padding(
                                padding: const EdgeInsets.all(26.0),
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Constants.primaryColor400),
                                  backgroundColor: Constants.primaryColor600,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            );
                          },
                          selector: (buildContext, userProvider) =>
                              userProvider.getPhotoUrl,
                        );
                      },
                      selector: (buildContext, userProvider) =>
                          userProvider.getGender,
                    ),
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
                      setState(() {
                        _isLoading = true;
                      });
                      Response response = await dio.get("/presigned");

                      imageCache.clear();

                      Provider.of<UserProvider>(context, listen: false)
                          .setUserData(
                              photoUrl: response.data["location"],
                              notify: true);

                      await http.put(response.data["uploadUrl"],
                          body: croppedFile.readAsBytesSync());
                      setState(() {
                        _isLoading = false;
                      });
                    } catch (exception, stackTrace) {
                      setState(() {
                        _isLoading = false;
                      });
                      print(exception);
                      await Sentry.captureException(
                        exception,
                        stackTrace: stackTrace,
                      );
                    }
                  }
                }
              } on PlatformException catch (e) {
                setState(() {
                  _isLoading = false;
                });
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
