
import 'package:boldo/network/files_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group('Filename from Dio header', (){

    test('Get filename', () {

      Headers headers = Headers();

      headers.add('content-disposition', 'filename=file');

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'file');
    });

    test('Get filename with extension', () {


      Headers headers = Headers();

      headers.add('content-disposition', 'filename=file.pdf');

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'file');

    });

    test('Get filename with extension and other content', () {


      Headers headers = Headers();

      headers.add('content-disposition', 'form-data; filename=filename.pdf');

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with extension and other content with file content', () {


      Headers headers = Headers();

      headers.add('content-disposition', 'form-data; filename=filename.pdf; name=filename');

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with file content and other content', () {


      Headers headers = Headers();

      headers.add('content-disposition', 'form-data; name=filename');

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with file content', () {


      Headers headers = Headers();

      headers.add('content-disposition', 'name=filename');

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with wrong content name', () {


      Headers headers = Headers();

      headers.add('Content-Disposition', 'name=filename');

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with missing content', () {


      Headers headers = Headers();

      headers.add('Content-type', 'application/pdf');

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, null);

    });

  });

  group('Filename from Http header', (){

    test('Get filename', () {

      Map<String, String> headers = {
        'content-disposition': 'filename=file',
      };

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'file');
    });

    test('Get filename with extension', () {


      Map<String, String> headers = {
        'content-disposition': 'filename=file.pdf',
      };

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'file');

    });

    test('Get filename with extension and other content', () {


      Map<String, String> headers = {
        'content-disposition': 'form-data; filename=filename.pdf',
      };

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with extension and other content with file content', () {


      Map<String, String> headers = {
        'content-disposition': 'form-data; filename=filename.pdf; name=filename',
      };

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with file content and other content', () {


      Map<String, String> headers = {
        'content-disposition': 'form-data; name=filename',
      };

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with file content', () {


      Map<String, String> headers = {
        'content-disposition': 'name=filename',
      };

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with wrong content name', () {


      Map<String, String> headers = {
        'Content-Disposition': 'name=filename',
      };

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, 'filename');

    });

    test('Get filename with missing content', () {


      Map<String, String> headers = {
        'Content-type': 'application/pdf',
      };

      String? filename = FilesRepository.getFilename(headers: headers);

      expect(filename, null);

    });

  });

}