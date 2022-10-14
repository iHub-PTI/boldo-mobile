import 'dart:io';

import 'package:boldo/constants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// This function receive a XFile picture from image_picker dependence,
/// [file] will be cropped by default with 1000x1000 and keeping its maximum resolution,
/// to reduce his resolution use [compressQuality] between 0 and 100
/// the aspects ratio resolution are square, 3x2, original, 4x3, 16x9
Future <File?> cropPhoto({
  required XFile file,
  int? maxHeight = 1000,
  int? maxWidth = 1000,
  int compressQuality  = 100,
}) async {
  File? croppedFile = await ImageCropper().cropImage(
    sourcePath: file.path,
    maxHeight: maxHeight,
    maxWidth: maxWidth,
    compressQuality: compressQuality,
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
    CropAspectRatioPreset.ratio16x9
    ],
    androidUiSettings: const AndroidUiSettings(
      toolbarTitle: 'Cropper',
      toolbarColor: ConstantsV2.orange,
      toolbarWidgetColor: ConstantsV2.lightest,
      initAspectRatio: CropAspectRatioPreset.original,
      lockAspectRatio: false
    ),
    iosUiSettings: const IOSUiSettings(
      title: 'Cropper',
    )
  );
  return croppedFile;
}