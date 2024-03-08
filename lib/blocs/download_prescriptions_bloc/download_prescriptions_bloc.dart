import 'dart:io';
import 'dart:typed_data';

import 'package:boldo/blocs/download_bloc/download_bloc.dart';
import 'package:boldo/models/RemoteFile.dart';
import 'package:boldo/network/prescription_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/utils/files_helpers.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
part 'download_prescriptions_event.dart';
part 'download_prescriptions_state.dart';

class   DownloadPrescriptionsBloc extends DownloadBloc<DownloadPrescriptionsEvent, DownloadPrescriptionsState> {

  DownloadPrescriptionsBloc() : super(DownloadPrescriptionsInitial()) {
    on<DownloadPrescriptionsEvent>((event, emit) async {
      if (event is DownloadPrescriptions) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get file of prescription selected',
          bindToScope: true,
        );
        emit(Loading());
        late Either<Failure, RemoteFile> _post;
        await Task(() => PrescriptionRepository.downloadPrescriptions(prescriptionsId: event.listOfIds))
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
          emitSnackBar(
              context: event.context,
              text: _post.asLeft().message,
              status: ActionStatus.Fail
          );
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          Uint8List file = _post.asRight().file;

          //open the file
          FilesHelpers.openFile(
            file: file,
            fileName: _post.asRight().name,
            extension: '.pdf',
          );
          emit(Success(file: file));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    });
  }

}
