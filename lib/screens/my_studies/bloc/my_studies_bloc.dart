import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:boldo/network/my_studies_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../models/DiagnosticReport.dart';

part 'my_studies_event.dart';
part 'my_studies_state.dart';

class MyStudiesBloc extends Bloc<MyStudiesEvent, MyStudiesState> {
  final MyStudesRepository _myStudiesRepository = MyStudesRepository();

  MyStudiesBloc() : super(MyStudiesInitial()) {
    on<MyStudiesEvent>((event, emit) async {
      if (event is GetPatientStudiesFromServer) {
        print('GetPatientStudiesFromServer capturado');
        emit(Loading());
        var _post;
        await Task(() => 
               _myStudiesRepository.getDiagnosticReports()!)
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
      }else if (event is GetPatientStudyFromServer) {
        emit(Loading());
        var _post;
        await Task(() =>
        _myStudiesRepository.getDiagnosticReport(event.id)!)
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
      }else if (event is SendStudyToServer) {
        emit(Uploading());
        var _post;
        await Task(() =>
        _myStudiesRepository.sendDiagnosticReport(event.diagnosticReport, event.files)!)
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
      }
    });
  }
}
