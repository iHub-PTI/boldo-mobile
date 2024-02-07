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
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../models/DiagnosticReport.dart';
import 'package:http/http.dart' as http;
part 'study_detail_event.dart';
part 'study_detail_state.dart';

class StudyDetailBloc extends Bloc<StudyDetailEvent, StudyDetailState> {
  final MyStudesRepository _myStudiesRepository = MyStudesRepository();
  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();

  StudyDetailBloc() : super(StudyDetailInitial()) {
    on<StudyDetailEvent>((event, emit) async {
      if (event is GetPatientStudyFromServer) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get a diagnostic report',
          bindToScope: true,
        );
        emit(Loading());
        var _post;
        await Task(() => _myStudiesRepository.getDiagnosticReport(event.id)!)
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          emit(DiagnosticStudyLoaded(study: _post.value));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }if (event is GetUserPdfFromUrl) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'download pdf of diagnostic report',
          bindToScope: true,
        );
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
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          emit(Success());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
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
