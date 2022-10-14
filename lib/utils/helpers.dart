import 'dart:io';

import 'package:boldo/main.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

String getDoctorPrefix(String gender) {
  if (gender == "female") return "Dra. ";
  if (gender == "male") return 'Dr. ';
  return "";
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String toLowerCase(String word){
  var words = word.split(" ");
  String _result = "";
  for(String a in words){
    if(a!= "")
    _result += "${a[0].toUpperCase()}${a.substring(1).toLowerCase()} ";
  }
  return "$_result".trimRight();
}

String? spanishGenderToEnglish(String? word){
  if(word == null){
    return null;
  }
  if(word.toLowerCase() == 'masculino')
    return 'male';
  if(word.toLowerCase() == 'femenino')
    return 'female';
  return 'unknow';
}

String? getTypeFromContentType(String? content) {
  try{
    if(content == null){
      return null;
    }
    var words = content.split("/");
    return words[1];
  }catch (e){
    Sentry.captureException(e);
    return null;
  }
}

/// set local date with format aaaa-mm-dd 00:00.000 for prevent days difference
/// get a bug, e.g: 30/06 21:00hs difference with 01/07 18:00, days difference
/// is calculated whit hours differences resulting <24:hs -> days = 0, therefore
/// this is presented like the same day
int daysBetween(DateTime from, DateTime to) {
   from = DateTime(from.year, from.month, from.day);
   to = DateTime(to.year, to.month, to.day);
 return (to.difference(from).inHours / 24).round();
}

/// return a String that represent the days in a past time
///
/// if [days] < 0 return 'día inválido'
///
/// if [days]== 0 return 'hoy'
///
/// if 0<[days]<=7 return 'hace [days] días'
///
/// if [showDateFormat] is true and [days] > 7 return a date in the format dd/mm/aaaa calculate [DateTime.now] - [days]
///
/// if [showDateFormat] is false and [days] > 7 return 'hace [days] días'
String passedDays(int days, {bool showDateFormat = true}) {
  if(days <0) {
    return 'día inválido';
  }else if( days == 0){
    return 'hoy';
  }else if( days == 1){
    return 'ayer';
  }else if( days <= 7){
    return 'hace $days días';
  }else{
    if(showDateFormat) {
      var outputFormat = DateFormat('dd/MM/yyyy');
      return outputFormat.format(DateTime.now().subtract(Duration(days: days)))
          .toString();
    }
    return 'hace $days días';
  }
}


Future<XFile?> pickImage({
  required BuildContext context,
  required ImageSource source,
  double? maxWidth,
  double? maxHeight,
  int? imageQuality,
  String? permissionDescription})
async {
  PermissionStatus status;
  if(source.index == 0) // camera source
    status = await Permission.camera.request();
  else
    status = await Permission.photos.request();
  print(status);
  if(status.isPermanentlyDenied) {
    // control permission to access camera
    if(source.index == 0)
      dialogPermission(
          context: context,
          permissionTitle: 'Acesso a Camara',
          permissionDescription: permissionDescription?? 'Boldo requiere acceso a la camara');

    // control permission to access gallery
    if(source.index == 1)
      dialogPermission(
          context: context,
          permissionTitle: 'Acesso a Galería',
          permissionDescription: permissionDescription?? 'Boldo requiere acceso a la galería');
    return null;
  }else if(status.isGranted){
    XFile? image;
    try {
      image = await ImagePicker().pickImage(source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality);
    }on PlatformException catch (e){
      // control permission to access camera
      await Sentry.captureMessage(
        e.toString(),
        params: [
          {
            "status": status,
            "patient": prefs.getString("userId"),
          }
        ],
      );
    }
    return image;
  }

}

Future<FilePickerResult?> pickFiles({
  required BuildContext context,
  bool allowMultiple = false,
  bool withData = false,
  FileType type = FileType.any,
  List<String>? allowedExtensions,
  String? permissionDescription})
async {
  FilePickerResult? result;
  PermissionStatus status;
  status = await Permission.storage.request();
  if(status.isPermanentlyDenied){
    dialogPermission(
        context: context,
        permissionTitle: 'Acesso a Archivos',
        permissionDescription: permissionDescription?? 'Boldo requiere acceso a archivos');
  }else if(status.isGranted){
    try {
      result = await FilePicker.platform.pickFiles(
        withData: withData,
        allowMultiple: allowMultiple,
        type: type,
        allowedExtensions: allowedExtensions,
      );
      return result;
    }on PlatformException catch (ex){
      await Sentry.captureMessage(
        ex.toString(),
        params: [
          {
            "status": status,
            "patient": prefs.getString("userId"),
          }
        ],
      );
    }
  }
  return result;

}

Future dialogPermission({
  required BuildContext context,
  required String permissionTitle,
  required String permissionDescription
  }){
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          // Android-specific code
          return AlertDialog(
            title: Text(permissionTitle),
            content: Text(permissionDescription),
            actions: <Widget>[
              TextButton(
                child: const Text('Rechazar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Settings'),
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              ),
            ],
          );
        } else
          // iOS-specific code
          return CupertinoAlertDialog(
          title: Text(permissionTitle),
          content: Text(permissionDescription),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Rechazar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: const Text('Settings'),
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
            ),
          ],
        );
      } );
}

Future<bool> checkQRPermission({
  required BuildContext context,
  String? permissionDescription})
async {
  PermissionStatus status;
  status = await Permission.camera.request();
  print(status);
  if(status.isPermanentlyDenied || status.isDenied) {
    // control permission to access camera
    await dialogPermission(
        context: context,
        permissionTitle: 'Acesso a Camara',
        permissionDescription: permissionDescription?? 'Boldo requiere acceso a la camara');
    return false;


  }else if(status.isGranted){
    return true;
  }
  else
    return false;

}

Future<bool> checkCameraPermission({
  required BuildContext context,
  String? permissionDescription})
async {
  PermissionStatus status;
  status = await Permission.camera.request();
  if(!status.isGranted){
    // control permission to access camera
    await dialogPermission(
        context: context,
        permissionTitle: 'Acesso a Camara',
        permissionDescription: permissionDescription?? 'Boldo requiere acceso a la camara');
    return false;

  }else
    return true;

}

Future<bool> checkMicrophonePermission({
  required BuildContext context,
  String? permissionDescription})
async {
  PermissionStatus status;
  status = await Permission.microphone.request();
  if(!status.isGranted){
    // control permission to access camera
    await dialogPermission(
        context: context,
        permissionTitle: 'Acesso a Microfono',
        permissionDescription: permissionDescription?? 'Boldo requiere acceso al microfono');
    return false;

  }else
    return true;

}