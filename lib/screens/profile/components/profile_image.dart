import 'package:boldo/constants.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/photos_helpers.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../main.dart';
import '../../../network/http.dart';

class ProfileImageEdit extends StatefulWidget {
  const ProfileImageEdit({Key? key}) : super(key: key);

  @override
  _ProfileImageEditState createState() => _ProfileImageEditState();
}

class _ProfileImageEditState extends State<ProfileImageEdit> {
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
            child: editingPatient.photoUrl == null || editingPatient.photoUrl == ''
                ?
            SvgPicture.asset(
              editingPatient.gender != null ? editingPatient.gender == "female"
                  ? 'assets/images/femalePatient.svg'
                  : editingPatient.gender == "male"
                  ? 'assets/images/malePatient.svg'
                  :'assets/images/LogoIcon.svg'
                  : 'assets/images/LogoIcon.svg',
            )
                :CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: editingPatient.photoUrl!,
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
                )
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
                XFile? result =
                    await pickImage(
                      context: context,
                      source: ImageSource.gallery,
                      permissionDescription: 'Se requiere acceso para seleccionar fotos'
                    );
                if (result != null) {
                  File? croppedFile = await cropPhoto(file: result);

                  if (croppedFile != null) {
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      Response response = await dio.get("/presigned");

                      imageCache!.clear();

                      var response2  = await http.put(Uri.parse(response.data["uploadUrl"]),
                          body: croppedFile.readAsBytesSync());
                      if(response2.statusCode == 413){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                          content: Text("El tamaño de la foto es muy grande"),
                          backgroundColor: Colors.redAccent,
                          ),
                        );
                      }else if(response2.statusCode == 201){
                        editingPatient.photoUrl = response.data["location"];
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ocurrio un error"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    } catch (exception, stackTrace) {
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ocurrio un error"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      print(exception);
                      await Sentry.captureMessage(
                          exception.toString(),
                          params: [
                            {
                              'patient': prefs.getString("userId"),
                              'access_token': await storage.read(key: 'access_token')
                            },
                            stackTrace
                          ]
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

class ProfileImageView extends StatefulWidget {

  final double height;
  final double width;
  final bool border;

  const ProfileImageView({
    Key? key,
    required this.height,
    required this.width,
    required this.border,
  }) : super(key: key);

  @override
  _ProfileImageViewState createState() => _ProfileImageViewState();
}

class _ProfileImageViewState extends State<ProfileImageView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: widget.height,
          width: widget.width,
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
                child: patient.photoUrl == null || patient.photoUrl == ''
                ?
                SvgPicture.asset(
                  patient.gender != null ? patient.gender == "female"
                      ? 'assets/images/femalePatient.svg'
                      : patient.gender == "male"
                        ? 'assets/images/malePatient.svg'
                        :'assets/images/LogoIcon.svg'
                    : 'assets/images/LogoIcon.svg',
                )
                :CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: patient.photoUrl!,
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
                )
              ),
            elevation: 4.0,
            shape: widget.border ? const StadiumBorder(
              side: BorderSide(
                color: Colors.white,
                width: 3,
              )
            ) : const CircleBorder(),
            clipBehavior: Clip.antiAlias,
          ),
        ),
      ],
    );
  }
}

class ProfileImageView2 extends StatefulWidget {

  final double height;
  final double width;
  final bool border;
  final Patient? patient;
  final Color? color;

  const ProfileImageView2({
    Key? key,
    required this.height,
    required this.width,
    required this.border,
    required this.patient,
    this.color,
  }) : super(key: key);

  @override
  _ProfileImageViewState2 createState() => _ProfileImageViewState2();
}

class _ProfileImageViewState2 extends State<ProfileImageView2> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: widget.height,
          width: widget.width,
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
              child: widget.patient != null ? widget.patient!.photoUrl == null || widget.patient!.photoUrl == '' ?
                SvgPicture.asset(
                  widget.patient!.gender == null || widget.patient!.gender == 'unknown'
                      ? 'assets/images/LogoIcon.svg'
                      : widget.patient!.gender == "female"
                      ? 'assets/images/femalePatient.svg'
                      : 'assets/images/malePatient.svg',
                ) :
               CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.patient!.photoUrl!,
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
              ): SvgPicture.asset('assets/images/LogoIcon.svg')

            ),
            elevation: 4.0,
            shape: widget.border ? StadiumBorder(
                side: BorderSide(
                  color: widget.color?? Colors.white,
                  width: 3,
                )
            ) : const CircleBorder(),
            clipBehavior: Clip.antiAlias,
          ),
        ),
      ],
    );
  }
}


/// Image profile form url o default defined in [Patient] o the global patient
/// The forms accepted are "rounded" and "square", by default is "rounded"
class ProfileImageViewTypeForm extends StatefulWidget {

  final double height;
  final double width;
  final bool border;
  final Patient? patient;
  final String form;

  const ProfileImageViewTypeForm({
    Key? key,
    required this.height,
    required this.width,
    required this.border,
    this.patient,
    this.form = "rounded"
  }) : super(key: key);

  @override
  _ProfileImageViewTypeForm createState() => _ProfileImageViewTypeForm();
}

class _ProfileImageViewTypeForm extends State<ProfileImageViewTypeForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: widget.height,
          width: widget.width,
          child: Card(
            child: widget.patient == null
            ? prefs.getString('profile_url') == '' ?
            SvgPicture.asset(
              prefs.getString('gender') == 'unknown'
                  ? 'assets/images/LogoIcon.svg'
                  : prefs.getString('gender') == "female"
                  ? 'assets/images/femalePatient.svg'
                  : 'assets/images/malePatient.svg',
            ) : CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: prefs.getString('profile_url')?? '',
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
            )
            : widget.patient!.photoUrl == null || widget.patient!.photoUrl == '' ?
            SvgPicture.asset(
              widget.patient!.gender == null || widget.patient!.gender == 'unknown'
                  ? 'assets/images/LogoIcon.svg'
                  : widget.patient!.gender == "female"
                  ? 'assets/images/femalePatient.svg'
                  : 'assets/images/malePatient.svg',
            ) :
            CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.patient!.photoUrl!,
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
            ),
            shape: widget.form == "rounded" ? StadiumBorder(
                side: widget.border ? const BorderSide(
                  color: Colors.white,
                  width: 3,
                ) : BorderSide.none,
            ) : widget.form == "square" ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3)) : const CircleBorder(),
            clipBehavior: Clip.antiAlias,
          ),
        ),
      ],
    );
  }
}

/// Image profile form url, [gender] define an default profile image if [photoUrl]
/// is null.
/// The forms accepted are "rounded" and "square", by default is "rounded"
class ImageViewTypeForm extends StatefulWidget {

  final double height;
  final double width;
  final bool border;
  final String? photoUrl;
  final String? gender;
  final String form;

  const ImageViewTypeForm({
    Key? key,
    required this.height,
    required this.width,
    required this.border,
    this.photoUrl,
    this.gender,
    this.form = "rounded"
  }) : super(key: key);

  @override
  _ImageViewTypeForm createState() => _ImageViewTypeForm();
}

class _ImageViewTypeForm extends State<ImageViewTypeForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: widget.height,
          width: widget.width,
          child: Card(
            child: widget.photoUrl == null ?
            SvgPicture.asset(
              widget.gender == 'male'
                  ? 'assets/images/malePatient.svg'
                  : prefs.getString('gender') == "female"
                  ? 'assets/images/femalePatient.svg'
                  : 'assets/images/LogoIcon.svg',
            ) : CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.photoUrl?? '',
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
            ),
            shape: widget.form == "rounded" ? StadiumBorder(
              side: widget.border ? const BorderSide(
                color: Colors.white,
                width: 3,
              ) : BorderSide.none,
            ) : widget.form == "square" ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3)) : const CircleBorder(),
            clipBehavior: Clip.antiAlias,
          ),
        ),
      ],
    );
  }
}