import 'dart:io';
import 'dart:math';

import 'package:boldo/constants.dart';
import 'package:boldo/main.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
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
String passedDays(int days, {bool showDateFormat = true, bool showPrefixText = false}) {
  if(days <0) {
    return 'día inválido';
  }else if( days == 0){
    return '${showPrefixText? 'Realizado ': ''}hoy';
  }else if( days == 1){
    return '${showPrefixText? 'Realizado ': ''}ayer';
  }else if( days <= 7){
    return '${showPrefixText? 'Realizado ': ''}hace $days días';
  }else{
    if(showDateFormat) {
      var outputFormat = DateFormat('dd/MM/yyyy');
      return "${showPrefixText? 'Realizado el ': ''}${outputFormat.format(DateTime.now().subtract(Duration(days: days)))
          .toString()}";
    }
    return '${showPrefixText? 'Realizado ': ''}hace $days días';
  }
}

/// return a String that represent the difference between dates to reach the current date
String? dateBetween({DateTime? date, String? afterText}) {

  if(date!=  null){

    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    date = DateTime(date.year, date.month, date.day);

    int difference = date.difference(today).inDays ;

    if (difference <= -365){
      int year = date.year - today.year;
      if(year==-1){
        return 'Realizado hace un año';
      }else{
        return 'Realizado hace ${year.abs()} años';
      }
    }else if(difference< 0 ) {
      int month = date.month - today.month + (date.year - today.year)*12;
      if(difference <-60){
        return 'Realizado hace ${month.abs()} meses';
      }else if(difference <-31){
        return 'Realizado hace un mes';
      }else if(difference == -1){
        return "Realizado ayer";
      }
      return 'Realizado hace ${difference.abs()} días';
    }else if(difference == 0){
      return 'Hoy';
    }else{
      if (difference > 365){
        int year = date.year - today.year;
        if(year==1){
          return 'Falta un año ${afterText?? ''}';
        }else{
          return 'Faltan ${year.abs()} años ${afterText?? ''}';
        }
      }else if(difference> 0 ) {
        int month = date.month - today.month + (date.year - today.year)*12;
        if(difference >60){
          return 'Faltan ${month.abs()} meses ${afterText?? ''}';
        }else if(difference >31){
          return 'Falta un mes ${afterText?? ''}';
        }else if(difference == 1){
          return "Mañana";
        }
        return 'Falta ${difference.abs()} días ${afterText?? ''}';
      }
    }
  }
  return null;
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
            'access_token': await storage.read(key: 'access_token')
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
            'access_token': await storage.read(key: 'access_token')
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

String? removeInternationalPyNumber(String? number){
  if((number?.length?? 0) >= 4){
    if(number?.substring(0,4) == '+595'){
      return number?.substring(4);
    }
  }
  return number;
}

String? addInternationalPyNumber(String? number){
  if(number != null){
    return '+595' + number;
  }
  return number;
}


/// Class to format a valid date to input un TextFormField
/// this will autocomplete with / in the form "1" after typing a second character
/// the / is inserted in the form "1/2"
class DateTextFormatter extends TextInputFormatter {
  static const _maxChars = 8;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String separator = '/';
    var text = _format(
      newValue.text,
      oldValue.text,
      separator,
    );

    return newValue.copyWith(
      text: text,
      selection: updateCursorPosition(
        oldValue,
        text,
      ),
    );
  }

  String _format(
      String value,
      String oldValue,
      String separator,
      ) {
    var isErasing = value.length < oldValue.length;
    var isComplete = value.length > _maxChars + 2;

    if (!isErasing && isComplete) {
      return oldValue;
    }

    value = value.replaceAll(separator, '');
    final result = <String>[];

    for (int i = 0; i < min(value.length, _maxChars); i++) {
      result.add(value[i]);
      if ((i == 1 || i == 3) && i != value.length - 1) {
        result.add(separator);
      }
    }

    return result.join();
  }

  TextSelection updateCursorPosition(
      TextEditingValue oldValue,
      String text,
      ) {
    var endOffset = max(
      oldValue.text.length - oldValue.selection.end,
      0,
    );

    var selectionEnd = text.length - endOffset;

    return TextSelection.fromPosition(TextPosition(offset: selectionEnd));
  }
}

enum ActionStatus {Success, Fail}

void emitSnackBar({required BuildContext context, String? text, ActionStatus? status, Widget? icon, Color? color}){

  String? message = text;

  switch (status) {
    case ActionStatus.Success:
      message = message?? "Acción exitosa";
      color = color?? ConstantsV2.systemSuccess;
      icon = icon?? SvgPicture.asset('assets/icon/check-circle2.svg');
      break;
    case ActionStatus.Fail:
      message = message?? "Acción fallida";
      color = color?? ConstantsV2.systemFail;
      icon = icon?? SvgPicture.asset('assets/icon/close_black.svg', color: const Color(0xffFBFBFB),);
      break;
    default: // Without this, you see a WARNING.
      message = message?? "Acción con estado desconocido";
      color = color?? ConstantsV2.secondaryRegular;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 1,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
      content: Row(
        children: [
          if(icon != null)
            icon,
          const Padding(padding: EdgeInsets.only(left: 8)),
          Expanded(
            child: Text(
                message,
                style: boldoCorpMediumBlackTextStyle
                    .copyWith(color: ConstantsV2.lightGrey)
            ),
          )
        ],
      ),
      backgroundColor: color,
    ),
  );
}


enum AppointmentType {InPerson, Virtual}