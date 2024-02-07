
import 'package:boldo/models/MedicalRecord.dart';
import 'package:boldo/models/StudyOrder.dart';
import 'package:boldo/network/order_study_repository.dart';
import 'package:boldo/network/repository_helper.dart';
import 'package:boldo/network/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'medicalRecordEvent.dart';
part 'medicalRecordState.dart';

class MedicalRecordBloc extends Bloc<MedicalRecordEvent, MedicalRecordState> {
  final UserRepository _patientRepository = UserRepository();
  final StudiesOrdersRepository _ordersRepository = StudiesOrdersRepository();
  MedicalRecordBloc() : super(MedicalRecordInitial()) {
    on<MedicalRecordEvent>((event, emit) async {
      if (event is GetMedicalRecord) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get appointment annotation and indications (encounter)',
          bindToScope: true,
        );
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getMedicalRecordByAppointment(event.appointmentId)!)
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
          late MedicalRecord medicalRecord;
          _post.foldRight(MedicalRecord, (a, previous) => medicalRecord = a);
          emit(MedicalRecordLoadedState(medicalRecord: medicalRecord));
          emit(Success());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }else if (event is GetMedicalRecordById) {
        ISentrySpan transaction = Sentry.startTransaction(
          event.runtimeType.toString(),
          'GET',
          description: 'get appointment annotation and indications (encounter)',
          bindToScope: true,
        );
        emit(Loading());
        var _post;
        await Task(() =>
        _patientRepository.getMedicalRecordById(event.id)!)
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
          late MedicalRecord medicalRecord;
          _post.foldRight(MedicalRecord, (a, previous) => medicalRecord = a);
          emit(MedicalRecordLoadedState(medicalRecord: medicalRecord));
          emit(Success());
          transaction.finish(
            status: const SpanStatus.ok(),
          );
        }
      }else if(event is InitialEvent){
        emit(MedicalRecordInitial());
      }
    }

    );
  }
}
