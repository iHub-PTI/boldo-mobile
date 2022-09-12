import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:boldo/network/my_studies_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../models/DiagnosticReport.dart';
import 'package:http/http.dart' as http;
part 'my_studies_event.dart';
part 'my_studies_state.dart';

class MyStudiesBloc extends Bloc<MyStudiesEvent, MyStudiesState> {
  final MyStudesRepository _myStudiesRepository = MyStudesRepository();
  List<File> files = [];

  MyStudiesBloc() : super(MyStudiesInitial()) {
    on<MyStudiesEvent>((event, emit) async {
      if (event is GetPatientStudiesFromServer) {
        print('GetPatientStudiesFromServer capturado');
        emit(Loading());
        var _post;
        await Task(() => _myStudiesRepository.getDiagnosticReports()!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(msg: response));
        } else {
          emit(DiagnosticLoaded(studiesList: _post.value));
        }
      } else if (event is GetPatientStudyFromServer) {
        emit(Loading());
        var _post;
        await Task(() => _myStudiesRepository.getDiagnosticReport(event.id)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(msg: response));
        } else {
          emit(DiagnosticStudyLoaded(study: _post.value));
        }
      } else if (event is SendStudyToServer) {
        emit(Uploading());
        var _post;
        await Task(() => _myStudiesRepository.sendDiagnosticReport(
                event.diagnosticReport, event.files)!)
            .attempt()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(FailedUpload(msg: response));
        } else {
          emit(Uploaded());
        }
      } else if (event is GetUserPdfFromUrl) {
        emit(Loading());
        var _post;
        await Task(() => getUserPdfVisor(event.url)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        });
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(msg: response));
        } else {
          emit(Success());
        }
      }else if(event is DeleteFiles){
        files = [];
      }else if(event is AddFiles){
        if (files.isNotEmpty) {
          files = [
            ...files,
            ...event.files
          ];
        } else {
          files = event.files;
        }
      }else if(event is AddFile){
        if (files.isNotEmpty) {
          files = [
            ...files,
            event.file
          ];
        } else {
          files = [event.file];
        }
      }else if(event is GetFiles){
        emit(FilesObtained(files: files));
      }
    });
  }
  Future<None>? getUserPdfVisor(final url) async {
    var fileName = 'visor';
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" + fileName + ".pdf");
      print(dir.path);
      File urlFile = await file.writeAsBytes(bytes);
      OpenFilex.open(urlFile.path);
       return const None();
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }
}
