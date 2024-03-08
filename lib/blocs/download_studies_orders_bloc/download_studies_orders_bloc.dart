import 'dart:io';
import 'dart:typed_data';

import 'package:boldo/blocs/download_bloc/download_bloc.dart';
import 'package:boldo/models/RemoteFile.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/files_helpers.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
part 'download_studies_orders_event.dart';
part 'download_studies_orders_state.dart';

class DownloadStudiesOrdersBloc extends DownloadBloc<DownloadStudiesOrdersEvent, DownloadStudiesOrdersState> {

  DownloadStudiesOrdersBloc() : super(DownloadStudiesOrdersInitial()) {
    on<DownloadStudiesOrdersEvent>((event, emit) async {
      if (event is DownloadStudiesOrders) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get file of studies selected',
          bindToScope: true,
        );
        emit(Loading());
        var _post;
        await Task(() => StudiesOrdersRepository.downloadStudiesOrders(studiesOrdersId: event.listOfIds))
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
          emitSnackBar(
              context: event.context,
              text: _post.asLeft().message,
              status: ActionStatus.Fail
          );
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          late Uint8List file;
          _post.foldRight(Uint8List, (a, previous) => file = a);

          //open the file
          FilesHelpers.openFile(file: file, extension: '.pdf');
          emit(Success(file: file));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    });
  }

}
