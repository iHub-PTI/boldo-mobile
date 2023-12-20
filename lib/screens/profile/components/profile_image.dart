import 'dart:ui';

import 'package:boldo/constants.dart';
import 'package:boldo/models/Patient.dart';
import 'package:boldo/models/upload_url_model.dart';
import 'package:boldo/network/files_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/errors.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:boldo/utils/photos_helpers.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../main.dart';

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
                  :'assets/images/persona.svg'
                  : 'assets/images/persona.svg',
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
                      UploadUrl response = await FilesRepository.getUploadURL();

                      imageCache!.clear();

                      await FilesRepository.uploadFile(
                        file: File(result.path),
                        url: response,
                      );

                      editingPatient.photoUrl = response.location;
                      setState(() {
                        _isLoading = false;
                      });
                    } on Failure catch (exception, stackTrace) {
                      setState(() {
                        _isLoading = false;
                      });
                      emitSnackBar(
                          context: context,
                          text: exception.message,
                          status: ActionStatus.Fail
                      );
                      captureMessage(
                        message: exception.message,
                        stackTrace: stackTrace,
                        response: exception.response,
                      );
                    } on DioError catch (exception, stackTrace) {
                      setState(() {
                        _isLoading = false;
                      });
                      emitSnackBar(
                          context: context,
                          text: exception.message,
                          status: ActionStatus.Fail
                      );
                      captureError(
                        exception: exception,
                        stackTrace: stackTrace,
                      );
                    } on Exception catch (exception, stackTrace) {
                      setState(() {
                        _isLoading = false;
                      });
                      emitSnackBar(
                          context: context,
                          text: genericError,
                          status: ActionStatus.Fail
                      );
                      captureError(
                        exception: exception,
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

@deprecated
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

@deprecated
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

/// Image profile form url, [gender] define an default profile image if [photoUrl]
/// is null.
/// The forms accepted are "rounded" and "square", by default is "rounded"
class ImageViewTypeForm extends StatefulWidget {

  final double height;
  final double width;
  final Color? color;
  final Color? backgroundColor;
  final double opacity;
  final bool border;
  final Color? borderColor;
  final bool blur;
  final String? url;
  final String? gender;
  final String form;
  final bool isPatient;
  final double elevation;
  final String? text;
  final TextStyle? textStyle;

  const ImageViewTypeForm({
    Key? key,
    required this.height,
    required this.width,
    required this.border,
    this.gender,
    this.borderColor = Colors.white,
    this.backgroundColor,
    this.color,
    this.opacity = 1,
    this.blur = false,
    this.url,
    this.form = "rounded",
    this.isPatient = true,
    this.elevation = 1.0,
    this.text,
    this.textStyle,
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


    Widget child =
    widget.url != null && widget.url != ""
        ? CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: widget.url!,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          Padding(
            padding: const EdgeInsets.all(26.0),
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                  Constants.primaryColor400),
              backgroundColor: Constants.primaryColor600,
            ),
          ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      imageBuilder: widget.color != null ? (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter:
              ColorFilter.mode(widget.color!, BlendMode.color)),
        ),
      ) : null,
    )
        : widget.text != null
        ? Center(
      child: Text(
        widget.text?? '',
        style: widget.textStyle,
      ),
    )
        : SvgPicture.asset(
      widget.gender == 'male'
          ? widget.isPatient? 'assets/images/malePatient.svg': 'assets/images/maleDoctor.svg'
          : widget.gender == "female"
          ? widget.isPatient? 'assets/images/femalePatient.svg': 'assets/images/femaleDoctor.svg'
          : 'assets/images/persona.svg',
    );

    return Card(
      elevation: widget.elevation,
      margin: const EdgeInsets.all(0),
      child: Stack(
        children: [
          Container(
            child: child,
            color: widget.backgroundColor,
            height: widget.height,
            width: widget.width,
          ),
          Container(
            child: widget.blur ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Container(
                color: widget.color?.withOpacity(widget.opacity),
                width: widget.width,
                height: widget.height,
              ),
            ) :
            Container(
              color: widget.color?.withOpacity(widget.opacity),
              width: widget.width,
              height: widget.height,
            ),
            height: widget.height,
            width: widget.width,
          ),
        ],
      ),
      shape: widget.form == "rounded" ? StadiumBorder(
        side: widget.border ? BorderSide(
          color: widget.borderColor?? Colors.white,
          width: 2,
        ) : BorderSide.none,
      ) : widget.form == "square" ? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3)) : const CircleBorder(),
      clipBehavior: Clip.antiAlias,
    );

  }

}