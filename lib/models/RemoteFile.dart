import 'dart:typed_data';

class RemoteFile {

  Uint8List file;
  String? name;

  RemoteFile({
    required this.file,
    this.name,
  });

}