import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

abstract class FilesHelpers{

  ///[extension] must be start with dot ('.') character to interpret as an
  /// extension of a file or the file was saved without extension type like a
  /// byte file
  static void openFile({
    required Uint8List file,
    String fileName = "visor",
    String? extension,
  }) async{
    Directory dir = await getAppDirectory();
    File fileDirectory = File("${dir.path}/" + fileName + (extension?? ''));
    //write in memory the file to open
    File urlFile = await fileDirectory.writeAsBytes(file);
    OpenFilex.open(urlFile.path);
  }

  static Future<Directory> getAppDirectory() async {
    Directory dir = await getApplicationDocumentsDirectory();
    return dir;
  }

}