import 'package:boldo/models/QRCode.dart';
import 'package:boldo/network/family_repository.dart';
import 'package:boldo/network/qr_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../main.dart';


part 'qr_event.dart';
part 'qr_state.dart';

class QrBloc extends Bloc<QrBlocEvent, QrBlocState> {
  final FamilyRepository _familyRepository = FamilyRepository();
  final QRRepository _qrRepository = QRRepository();
  QrBloc() : super(QrInitialState()) {
    on<QrBlocEvent>((event, emit) async {
      if(event is ValidateQr) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'validate qr and get the patient',
          bindToScope: true,
        );
        emit(Loading());
        var _post;
        await Task(() =>
        _familyRepository.getDependent(event.qrCode)!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        }else{
          user.isNew = false;
          emit(QrDecoded());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
      else if(event is GetQRCode) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get Qr code of the principal patient',
          bindToScope: true,
        );
        emit(Loading());
        var _post;
        await Task(() =>
        _qrRepository.getQrCode()!)
            .attempt()
            .mapLeftToFailure()
            .run()
            .then((value) {
          _post = value;
        }
        );
        var response;
        if (_post.isLeft()) {
          _post.leftMap((l) => response = l.message);
          emit(Failed(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          late QRCode qrCode;
          _post.foldRight(QRCode, (a, previous) => qrCode = a);

          emit(QrObtained(qrCode: qrCode));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }

    );
  }
}
