import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/my_studies_repository.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../models/DiagnosticReport.dart';
import 'package:http/http.dart' as http;
part 'study_detail_event.dart';
part 'study_detail_state.dart';

class StudyDetailBloc extends Bloc<StudyDetailEvent, StudyDetailState> {
  final MyStudesRepository _myStudiesRepository = MyStudesRepository();
  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();
  List<File> files = [];

  StudyDetailBloc() : super(StudyDetailInitial()) {
    on<StudyDetailEvent>((event, emit) async {
      if (event is GetPatientStudyFromServer) {
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
      }if (event is GetUserPdfFromUrl) {
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
      } else if (event is DeleteFiles) {
        files = [];
      } else if (event is AddFiles) {
        if (files.isNotEmpty) {
          files = [...files, ...event.files];
        } else {
          files = event.files;
        }
      } else if (event is AddFile) {
        if (files.isNotEmpty) {
          files = [...files, event.file];
        } else {
          files = [event.file];
        }
      } else if (event is GetFiles) {
        emit(FilesObtained(files: files));
      } else if (event is GetServiceRequests) {
        emit(Loading());
        var _post;
        await Task(() =>
                _ordersRepository.getServiceRequestId(event.serviceRequestId)!)
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
          late ServiceRequest serviceRequest;
          _post.foldRight(StudyOrder, (a, previous) => serviceRequest = a);
          emit(ServiceRequestLoaded(serviceRequest: serviceRequest));
          emit(Success());
        }
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
