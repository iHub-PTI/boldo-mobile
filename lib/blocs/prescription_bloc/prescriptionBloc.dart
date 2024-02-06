
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';



part 'prescriptionEvent.dart';
part 'prescriptionState.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final UserRepository _patientRepository = UserRepository();
  PrescriptionBloc() : super(PrescriptionBlocInitial()) {
    on<PrescriptionEvent>((event, emit) async {
      if(event is GetPrescription){
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get prescription from encounter',
          bindToScope: true,
        );
        emit(LoadingPrescription());
        var _post;
        await Task(() =>
        _patientRepository.getPrescription(event.id)!)
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
          emit(FailedLoadPrescription(response: response));
          transaction.throwable = _post.asLeft();
          transaction.finish(
            status: SpanStatus.fromString(
              _post.asLeft().message,
            ),
          );
        } else {
          emit(PrescriptionLoaded(prescription: _post.value));
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }
    }

    );
  }
}
